/// `inquiry init` — initializes Inquiry in the working directory.
///
/// Idempotent steps:
/// 1. Create cleanrooms/ at project root if missing
/// 2. Add .inquiry/ and cleanrooms/**/.iq.state.yaml to .gitignore
/// 3. Create .inquiry/config.yaml with defaults (project-scoped)
/// 4. Deploy the inquiry agent into the repo for the selected host (repo-scoped,
///    like `git init`): `.opencode/agent/inquiry.md` (default) or
///    `.github/agents/inquiry.agent.md` (`--host copilot`)
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

  InitCommand(this.input, {this.assets});

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

    // Step 4: Deploy the repo-scoped agent for this host; first remove any
    // other host's agent so exactly one host is deployed at a time (#274).
    if (assets != null) {
      _cleanOtherHostAgents(root, steps);
      _deployAgent(root, assets!, steps);
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
  void _deployAgent(String root, Assets assets, List<String> steps) {
    final adapter = _adapterForHost(input.host)!;
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

  /// Removes the per-project agent of every supported host other than the one
  /// being initialized — enforces "one host at a time" even when switching
  /// hosts on an existing repo (#274). No-op on a fresh init.
  void _cleanOtherHostAgents(String root, List<String> steps) {
    for (final host in const ['claude', 'copilot', 'opencode']) {
      if (host == input.host) continue;
      final rel = _adapterForHost(host)?.projectAgentRelPath;
      if (rel == null) continue;
      final file = File(p.join(root, rel));
      if (file.existsSync()) {
        file.deleteSync();
        steps.add('Removed $host agent (${rel.replaceAll(r'\', '/')})');
      }
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
