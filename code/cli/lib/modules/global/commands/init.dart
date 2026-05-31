/// `inquiry init` — initializes Inquiry in the working directory.
///
/// Idempotent steps:
/// 1. Create cleanrooms/ at project root if missing
/// 2. Add .inquiry/ and cleanrooms/**/.iq.state.yaml to .gitignore
/// 3. Create .inquiry/config.yaml with defaults (project-scoped)
/// 4. Deploy inquiry.agent.md to .github/agents/ (repo-scoped)
///
/// Cycle runtime (`.iq.state.yaml`, `mutations.md`) is materialized per cycle
/// under `cleanrooms/<branch>/` by the FSM, not scaffolded at init.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../src/git_utils.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

/// Carries the working directory where APE will be initialized.
///
/// Defaults to [Directory.current] when constructed from a [CliRequest],
/// but accepts an explicit path for testing.
class InitInput extends Input {
  final String workingDirectory;

  InitInput({required this.workingDirectory});

  factory InitInput.fromCliRequest(CliRequest req) =>
      InitInput(workingDirectory: Directory.current.path);

  @override
  Map<String, dynamic> toJson() => {'workingDirectory': workingDirectory};
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
  String? validate() => null;

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

    // Step 4: Deploy inquiry.agent.md to .github/agents/ (repo-scoped)
    if (assets != null) {
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

  void _deployAgent(String root, Assets assets, List<String> steps) {
    final content = assets.loadString('agents/inquiry.agent.md');
    final agentFile = File(
      p.join(root, '.github', 'agents', 'inquiry.agent.md'),
    );
    agentFile.parent.createSync(recursive: true);
    agentFile.writeAsStringSync(content);
    steps.add('Deployed inquiry.agent.md to .github/agents/');
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

  /// Ensures `.inquiry/config.yaml` exists with default configuration.
  void _ensureConfigYaml(String root, List<String> steps) {
    final configDir = Directory('$root/.inquiry');
    final configFile = File('$root/.inquiry/config.yaml');

    if (!configFile.existsSync()) {
      if (!configDir.existsSync()) configDir.createSync(recursive: true);
      configFile.writeAsStringSync(
        'evolution:\n'
        '  enabled: false\n',
      );
      steps.add('Created .inquiry/config.yaml');
    }
  }

  String _relative(String root, String path) => p.relative(path, from: root);
}
