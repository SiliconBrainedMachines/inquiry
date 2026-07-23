/// `iq implementation start --issue <N>` — one command that takes a published
/// issue from "nothing" to a ready ANALYZE cycle.
///
/// It owns the whole mechanical bootstrap that `assets/instructions/
/// inquiry-start.md` used to hand to the LLM step by step (derive slug, create
/// the branch, scaffold the cleanroom, transition): a mechanical process is an
/// `iq` command, not an instruction. Concretely it:
///
///   1. resolves the git project root (auto-runs `init` if the workspace is missing),
///   2. reads the issue title from GitHub (`gh issue view`),
///   3. derives the `<NNN>-<slug>` branch and checks it out (creating it if new),
///   4. fires the `start_analyze` transition, whose existing `open_analysis_context`
///      effect scaffolds `cleanrooms/<branch>/analyze/`.
///
/// Its errors are exemplary (AC2): every failure states what went wrong and how
/// to fix it, with a concrete example. Its happy path does NOT print a "next
/// step" — that would bias the user and make the command flow-aware.
library;

import 'dart:convert';
import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../src/git_utils.dart';
import '../../fsm/commands/transition.dart';
import '../../global/commands/init.dart';
import '../branch_name.dart';

typedef GitCommandRunner =
    ProcessResult Function(String workingDirectory, List<String> arguments);

/// The title and state of a GitHub issue, or `null` when it cannot be read.
typedef IssueInfoProvider =
    ({String title, String state})? Function(
      String issue,
      String workingDirectory,
    );

/// Runs the `start_analyze` transition and reports success + message.
typedef StartAnalyzeRunner =
    Future<({bool ok, String message})> Function({
      required String issue,
      required String workingDirectory,
      Assets? assets,
    });

// ─── Input ──────────────────────────────────────────────────────────────────

class ImplementationStartInput extends Input {
  final String issue;
  final String workingDirectory;

  ImplementationStartInput({
    required this.issue,
    required this.workingDirectory,
  });

  static final List<CliParam> params = [
    CliParam.string(
      'issue',
      required: true,
      description: 'The GitHub issue number to implement (e.g. --issue 40)',
    ),
  ];

  factory ImplementationStartInput.fromCliRequest(CliRequest req) =>
      ImplementationStartInput(
        issue: (req.flagString('issue') ?? '').trim(),
        workingDirectory: Directory.current.path,
      );

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() => {
    'issue': issue,
    'workingDirectory': workingDirectory,
  };
}

// ─── Output ─────────────────────────────────────────────────────────────────

class ImplementationStartOutput extends Output {
  final String issue;
  final String branch;
  final String cleanroom;
  final bool branchCreated;
  final bool initialized;

  ImplementationStartOutput({
    required this.issue,
    required this.branch,
    required this.cleanroom,
    required this.branchCreated,
    required this.initialized,
  });

  @override
  Map<String, dynamic> toJson() => {
    'issue': issue,
    'branch': branch,
    'cleanroom': cleanroom,
    'branch_created': branchCreated,
    'initialized': initialized,
  };

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() {
    final buffer = StringBuffer();
    if (initialized) {
      buffer.writeln('Initialized Inquiry workspace (.inquiry/).');
    }
    buffer.writeln('Implementation started for issue #$issue:');
    buffer.writeln(
      '  branch:    $branch ${branchCreated ? '(created)' : '(existing)'}',
    );
    buffer.writeln('  cleanroom: $cleanroom');
    buffer.write('  state:     ANALYZE');
    return buffer.toString();
  }
}

// ─── Command ────────────────────────────────────────────────────────────────

class ImplementationStartCommand
    implements Command<ImplementationStartInput, ImplementationStartOutput> {
  @override
  final ImplementationStartInput input;
  final Assets? _assets;
  final GitCommandRunner _git;
  final IssueInfoProvider _issueInfo;
  final StartAnalyzeRunner _startAnalyze;

  ImplementationStartCommand(
    this.input, {
    Assets? assets,
    GitCommandRunner? gitCommandRunner,
    IssueInfoProvider? issueInfoProvider,
    StartAnalyzeRunner? startAnalyzeRunner,
  }) : _assets = assets,
       _git = gitCommandRunner ?? _defaultGit,
       _issueInfo = issueInfoProvider ?? _defaultIssueInfo,
       _startAnalyze = startAnalyzeRunner ?? _defaultStartAnalyze;

  @override
  String? validate() {
    if (input.issue.isEmpty) {
      return 'Missing --issue.\n'
          'Usage: iq implementation start --issue <number>\n'
          'Example: iq implementation start --issue 40';
    }
    if (int.tryParse(input.issue) == null) {
      return 'The --issue value must be a number, got "${input.issue}".\n'
          'Usage: iq implementation start --issue <number>\n'
          'Example: iq implementation start --issue 40';
    }
    return null;
  }

  @override
  Future<ImplementationStartOutput> execute() async {
    final projectRoot = getProjectRoot(input.workingDirectory);
    if (projectRoot == null) {
      throw CommandException(
        code: 'NOT_A_GIT_REPO',
        message:
            'Not inside a git repository, so there is no place to open a cycle.\n'
            'Run `iq implementation start --issue ${input.issue}` from within your project, '
            'or initialize one first with `git init`.',
        exitCode: ExitCode.validationFailed,
      );
    }

    // AC3 — the workspace initializes itself when missing; the user never has
    // to remember `iq init`.
    final initialized = _ensureWorkspace(projectRoot);

    // Read the issue so the branch slug comes from its real title.
    final info = _issueInfo(input.issue, projectRoot);
    if (info == null) {
      throw CommandException(
        code: 'ISSUE_NOT_FOUND',
        message:
            'Could not read issue #${input.issue} from GitHub.\n'
            'Check that it exists and that `gh` is authenticated:\n'
            '  gh issue view ${input.issue}\n'
            '  gh auth status',
        exitCode: ExitCode.validationFailed,
      );
    }

    final String branch;
    try {
      branch = branchNameFor(issue: input.issue, title: info.title);
    } on ArgumentError catch (e) {
      throw CommandException(
        code: 'EMPTY_SLUG',
        message:
            '${e.message}\n'
            'Rename the issue to something with letters or numbers, then retry.',
        exitCode: ExitCode.validationFailed,
      );
    }

    final branchCreated = _checkoutBranch(projectRoot, branch);

    // Fire the real transition; its open_analysis_context effect scaffolds the
    // cleanroom under cleanrooms/<branch>/.
    final result = await _startAnalyze(
      issue: input.issue,
      workingDirectory: projectRoot,
      assets: _assets,
    );
    if (!result.ok) {
      throw CommandException(
        code: 'TRANSITION_FAILED',
        message:
            'Branch "$branch" is ready but the transition to ANALYZE failed:\n'
            '${result.message}',
        exitCode: ExitCode.genericError,
      );
    }

    return ImplementationStartOutput(
      issue: input.issue,
      branch: branch,
      cleanroom: p.posix.join('cleanrooms', branch),
      branchCreated: branchCreated,
      initialized: initialized,
    );
  }

  /// Ensures `.inquiry/config.yaml` exists; returns whether it had to create it.
  bool _ensureWorkspace(String projectRoot) {
    final config = File(p.join(projectRoot, '.inquiry', 'config.yaml'));
    if (config.existsSync()) return false;
    // InitCommand is idempotent and repo-scoped; reuse it rather than
    // reimplementing the workspace layout.
    InitCommand(InitInput(workingDirectory: projectRoot)).execute();
    return true;
  }

  /// Checks out [branch], creating it when it does not yet exist. Returns
  /// whether the branch was newly created.
  bool _checkoutBranch(String projectRoot, String branch) {
    final current = getCurrentBranch(projectRoot);
    if (current == branch) return false;

    final exists = _git(projectRoot, [
      'rev-parse',
      '--verify',
      '--quiet',
      'refs/heads/$branch',
    ]).exitCode == 0;

    final checkout = exists
        ? _git(projectRoot, ['checkout', branch])
        : _git(projectRoot, ['checkout', '-b', branch]);

    if (checkout.exitCode != 0) {
      throw CommandException(
        code: 'BRANCH_CHECKOUT_FAILED',
        message:
            'Could not switch to branch "$branch":\n'
            '${_gitError(checkout)}\n'
            'Commit or stash your changes, then retry `iq implementation start --issue ${input.issue}`.',
        exitCode: ExitCode.genericError,
      );
    }
    return !exists;
  }

  static String _gitError(ProcessResult r) {
    final err = r.stderr.toString().trim();
    if (err.isNotEmpty) return err;
    final out = r.stdout.toString().trim();
    return out.isNotEmpty ? out : 'git exited with code ${r.exitCode}';
  }

  static ProcessResult _defaultGit(
    String workingDirectory,
    List<String> arguments,
  ) => Process.runSync('git', arguments, workingDirectory: workingDirectory);

  static ({String title, String state})? _defaultIssueInfo(
    String issue,
    String workingDirectory,
  ) {
    try {
      final result = Process.runSync('gh', [
        'issue',
        'view',
        issue,
        '--json',
        'title,state',
      ], workingDirectory: workingDirectory);
      if (result.exitCode != 0) return null;
      final decoded =
          jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      final title = (decoded['title'] as String?)?.trim() ?? '';
      if (title.isEmpty) return null;
      return (title: title, state: (decoded['state'] as String?) ?? '');
    } catch (_) {
      return null;
    }
  }

  static Future<({bool ok, String message})> _defaultStartAnalyze({
    required String issue,
    required String workingDirectory,
    Assets? assets,
  }) async {
    final command = StateTransitionCommand(
      StateTransitionInput(
        currentState: null,
        event: 'start_analyze',
        issue: issue,
        workingDirectory: workingDirectory,
      ),
      assets: assets,
    );
    final output = await command.execute();
    return (ok: output.allowed, message: output.message);
  }
}
