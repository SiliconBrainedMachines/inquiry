/// `inquiry init` — initializes Inquiry in the working directory.
///
/// Idempotent steps:
/// 1. Create cleanrooms/ at project root if missing
/// 2. Add .inquiry/ and cleanrooms/**/.iq.state.yaml to .gitignore
/// 3. Create .inquiry/config.yaml with defaults (project-scoped)
/// 4. Deploy the inquiry agent + skills into the repo for the selected host
///    (repo-scoped, like `git init`; additive across hosts): e.g.
///    `.opencode/agent/inquiry.md` + `.opencode/skills/` (default), or
///    `.claude/agents/inquiry.md` + `.claude/skills/` (`--host claude`)
/// 5. OpenCode only: auto-configure Ollama num_ctx (#259)
///
/// Cycle runtime (`.iq.state.yaml`, `mutations.md`) is materialized per cycle
/// under `cleanrooms/<branch>/` by the FSM, not scaffolded at init.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../hosts/agent_builder.dart';
import '../../../hosts/claude_adapter.dart';
import '../../../hosts/copilot_adapter.dart';
import '../../../hosts/host_adapter.dart';
import '../../../hosts/opencode_adapter.dart';
import '../../../hosts/opencode_ollama_configurator.dart';
import '../../../src/git_utils.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

/// Carries the working directory where APE will be initialized.
///
/// Defaults to [Directory.current] when constructed from a [CliRequest],
/// but accepts an explicit path for testing.
class InitInput extends Input {
  final String workingDirectory;

  /// The host to deploy the repo-scoped agent for. Defaults to `opencode`.
  final String host;

  InitInput({required this.workingDirectory, this.host = 'opencode'});

  factory InitInput.fromCliRequest(CliRequest req) => InitInput(
        workingDirectory: Directory.current.path,
        host: req.flagString('host') ?? 'opencode',
      );

  @override
  Map<String, dynamic> toJson() => {
        'workingDirectory': workingDirectory,
        'host': host,
      };
}

/// Resolves a host name to its adapter, or `null` if unknown / no repo agent.
HostAdapter? _adapterForHost(String host) {
  switch (host) {
    case 'opencode':
      return OpenCodeAdapter();
    case 'copilot':
      return CopilotAdapter();
    case 'claude':
      return ClaudeAdapter();
    default:
      return null;
  }
}

// ─── Output ─────────────────────────────────────────────────────────────────

class InitOutput extends Output {
  final String message;
  final bool isCreated;

  InitOutput({required this.message, required this.isCreated});

  @override
  Map<String, dynamic> toJson() => {'message': message, 'created': isCreated};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

/// Initializes Inquiry in [InitInput.workingDirectory].
///
/// Idempotent: running twice produces the same result.
class InitCommand implements Command<InitInput, InitOutput> {
  @override
  final InitInput input;

  final Assets? assets;

  /// OpenCode-only: ensures configured Ollama models have an adequate `num_ctx`
  /// (#259). Injected; null disables it (e.g. in tests).
  final OpenCodeOllamaConfigurator? configurator;

  InitCommand(this.input, {this.assets, this.configurator});

  @override
  String? validate() {
    final adapter = _adapterForHost(input.host);
    if (adapter == null || adapter.projectAgentRelPath == null) {
      return 'Unknown or unsupported host: "${input.host}". '
          'Supported hosts: claude, copilot, opencode.';
    }
    return null;
  }

  @override
  Future<InitOutput> execute() async {
    final root = _resolveProjectRoot(input.workingDirectory);
    final steps = <String>[];

    // Step 1: Create cleanrooms/ at project root if missing
    final issuesDir = Directory('$root/cleanrooms');
    if (!issuesDir.existsSync()) {
      issuesDir.createSync(recursive: true);
      steps.add('Created ${_relative(root, issuesDir.path)}');
    }

    // Step 2: Add .inquiry/ and cycle-local state to .gitignore
    _ensureGitignore(root, steps);

    // Step 3: Create .inquiry/config.yaml with defaults (project-scoped)
    _ensureConfigYaml(root, steps);

    // Step 4: Deploy the repo-scoped agent + skills for this host. Additive —
    // other hosts deployed in this repo are left in place, so one repo can
    // serve multiple hosts (e.g. OpenCode + Claude) without duplication, since
    // each host reads its own isolated dir (#278).
    if (assets != null) {
      final adapter = _adapterForHost(input.host)!;
      _deployAgent(root, adapter, assets!, steps);
      _deploySkills(root, adapter, assets!, steps);
    }

    // Step 5: OpenCode silently truncates the firmware when Ollama's num_ctx is
    // too small (#259). Auto-configure it here (moved from the removed
    // `iq host get`).
    if (input.host == 'opencode' && configurator != null) {
      steps.addAll(await configurator!.configure());
    }

    if (steps.isEmpty) {
      return InitOutput(
        message: 'Inquiry already initialized in $root',
        isCreated: false,
      );
    }

    return InitOutput(message: steps.join('\n'), isCreated: true);
  }

  String _resolveProjectRoot(String workingDirectory) {
    return getProjectRoot(workingDirectory) ?? workingDirectory;
  }

  /// Deploys the inquiry agent into the repo for the selected host — repo-scoped
  /// like `git init`, never global (#272).
  void _deployAgent(
    String root,
    HostAdapter adapter,
    Assets assets,
    List<String> steps,
  ) {
    final rel = adapter.projectAgentRelPath!;
    final content = AgentBuilder(assets).build(adapter);
    final agentFile = File(p.join(root, rel));
    agentFile.parent.createSync(recursive: true);
    agentFile.writeAsStringSync(content);
    steps.add(
      'Deployed inquiry agent to ${rel.replaceAll(r'\', '/')} '
      '(host: ${input.host})',
    );
  }

  /// Deploys the inquiry skills into the repo for the selected host — repo-local,
  /// not global, so they appear only in this repo (#278).
  void _deploySkills(
    String root,
    HostAdapter adapter,
    Assets assets,
    List<String> steps,
  ) {
    final rel = adapter.projectSkillsRelPath;
    if (rel == null) return;
    final List<String> skillNames;
    try {
      skillNames = assets.listDirectory('skills');
    } catch (_) {
      return; // no skills bundled
    }
    for (final name in skillNames) {
      final content = assets.loadString('skills/$name/SKILL.md');
      final file = File(p.join(root, rel, name, 'SKILL.md'));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(content);
    }
    if (skillNames.isNotEmpty) {
      steps.add(
        'Deployed ${skillNames.length} skills to ${rel.replaceAll(r'\', '/')}/',
      );
    }
  }

  /// Ensures `.inquiry/` and cycle-local state are in `.gitignore`.
  void _ensureGitignore(String root, List<String> steps) {
    const entries = <String>['.inquiry/', 'cleanrooms/**/.iq.state.yaml'];
    final gitignore = File('$root/.gitignore');

    if (!gitignore.existsSync()) {
      gitignore.writeAsStringSync(
        '# Inquiry — local cycle state\n'
        '.inquiry/\n'
        'cleanrooms/**/.iq.state.yaml\n',
      );
      steps.add('Created .gitignore with Inquiry entries');
      return;
    }

    var content = gitignore.readAsStringSync();
    final missing = entries.where((e) => !content.contains(e)).toList();
    if (missing.isEmpty) return;

    if (!content.endsWith('\n')) content = '$content\n';
    content = '$content# Inquiry — local cycle state\n${missing.join('\n')}\n';
    gitignore.writeAsStringSync(content);
    steps.add('Added Inquiry entries to .gitignore');
  }

  /// Ensures `.inquiry/config.yaml` exists and records the chosen host.
  ///
  /// On a fresh repo it writes the defaults; on an existing repo it reconciles
  /// the `host:` line to the chosen host while preserving every other key
  /// (e.g. `evolution.enabled`), so switching hosts updates the record.
  void _ensureConfigYaml(String root, List<String> steps) {
    final configDir = Directory('$root/.inquiry');
    final configFile = File('$root/.inquiry/config.yaml');

    if (!configFile.existsSync()) {
      if (!configDir.existsSync()) configDir.createSync(recursive: true);
      configFile.writeAsStringSync(
        'host: ${input.host}\n'
        'evolution:\n'
        '  enabled: false\n',
      );
      steps.add('Created .inquiry/config.yaml');
      return;
    }

    final content = configFile.readAsStringSync();
    final hostLine = RegExp(r'^host:.*$', multiLine: true);
    final desired = 'host: ${input.host}';
    if (hostLine.hasMatch(content)) {
      if (hostLine.firstMatch(content)!.group(0) != desired) {
        configFile.writeAsStringSync(content.replaceFirst(hostLine, desired));
        steps.add('Updated host to ${input.host} in .inquiry/config.yaml');
      }
    } else {
      // Legacy config without a host line: prepend it, keep the rest.
      configFile.writeAsStringSync('$desired\n$content');
      steps.add('Recorded host: ${input.host} in .inquiry/config.yaml');
    }
  }

  String _relative(String root, String path) => p.relative(path, from: root);
}
