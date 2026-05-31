library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../fsm_contract.dart';
import '../../../src/git_utils.dart';
import '../../ape/inquiry_state.dart';
import '../effect_executor.dart';

typedef BranchProvider = Future<String> Function(String workingDirectory);
typedef GitCommandRunner =
    Future<ProcessResult> Function(
      String workingDirectory,
      List<String> arguments,
    );

const _requiredInspectionPasses = <String>[
  'Consistency',
  'Completeness',
  'Traceability',
];

final RegExp _inspectionCheckPattern = RegExp(
  r'^-\s+(PASS|FAIL|WARN):\s+(.+)$',
  caseSensitive: false,
);

final RegExp _fileLineCitationPattern = RegExp(
  r'(^|[\s(])([A-Za-z0-9._/-]+):(\d+)(?=$|[\s)])',
);

class _BoundaryCommitSpec {
  final String label;
  final String path;
  final String message;

  const _BoundaryCommitSpec({
    required this.label,
    required this.path,
    required this.message,
  });
}

class _BoundaryCommitResult {
  final List<String> operationsExecuted;
  final String? errorMessage;

  const _BoundaryCommitResult.success({this.operationsExecuted = const []})
    : errorMessage = null;

  const _BoundaryCommitResult.failure(this.errorMessage)
    : operationsExecuted = const [];
}

class _PrePrInspectionCheck {
  final String status;
  final String detail;

  const _PrePrInspectionCheck({required this.status, required this.detail});

  bool get requiresFileLineCitation => status == 'FAIL';

  bool get hasFileLineCitation => _fileLineCitationPattern.hasMatch(detail);
}

class _PrePrInspectionReport {
  final bool exists;
  final String? verdict;
  final Map<String, List<_PrePrInspectionCheck>> checksByPass;

  const _PrePrInspectionReport({
    required this.exists,
    required this.verdict,
    required this.checksByPass,
  });

  bool get hasRequiredPassStructure =>
      _requiredInspectionPasses.every(
        (pass) => (checksByPass[pass] ?? const <_PrePrInspectionCheck>[]).isNotEmpty,
      );

  bool get hasFailChecks => checksByPass.values
      .expand((checks) => checks)
      .any((check) => check.status == 'FAIL');

  bool get hasMissingRequiredCitations => checksByPass.values
      .expand((checks) => checks)
      .any(
        (check) =>
            check.requiresFileLineCitation && !check.hasFileLineCitation,
      );
}

class StateTransitionInput extends Input {
  final String? currentState;
  final String? event;
  final String? issue;
  final String workingDirectory;

  StateTransitionInput({
    required this.currentState,
    required this.event,
    this.issue,
    required this.workingDirectory,
  });

  factory StateTransitionInput.fromCliRequest(CliRequest req) {
    return StateTransitionInput(
      currentState: req.flagString('state', aliases: const ['s']),
      event: req.flagString('event', aliases: const ['e']),
      issue: req.flagString('issue', aliases: const ['i']),
      workingDirectory: Directory.current.path,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'currentState': currentState,
    'event': event,
    'issue': issue,
    'workingDirectory': workingDirectory,
  };
}

class StateTransitionOutput extends Output {
  final bool allowed;
  final String currentState;
  final String event;
  final String? nextState;
  final List<String> operationsExecuted;
  final String? promptFragmentId;
  final String? requiredRole;
  final List<String>? requiredInstructions;
  final String message;
  final int code;

  StateTransitionOutput({
    required this.allowed,
    required this.currentState,
    required this.event,
    required this.nextState,
    required this.operationsExecuted,
    required this.promptFragmentId,
    required this.requiredRole,
    required this.requiredInstructions,
    required this.message,
    required this.code,
  });

  @override
  Map<String, dynamic> toJson() => {
    'allowed': allowed,
    'current_state': currentState,
    'event': event,
    'next_state': nextState,
    'operations_executed': operationsExecuted,
    'prompt_fragment_id': promptFragmentId,
    'required_role': requiredRole,
    'required_instructions': requiredInstructions,
    'message': message,
  };

  @override
  int get exitCode => code;

  @override
  String? toText() {
    final instructions = requiredInstructions;
    if (instructions == null || instructions.isEmpty) {
      return message;
    }

    final buffer = StringBuffer()..writeln(message);
    buffer.writeln(
      requiredRole != null ? 'required_role: $requiredRole' : 'required_role: null',
    );
    buffer.writeln('required_instructions: ${instructions.join(', ')}');
    buffer.write(
      promptFragmentId != null
          ? 'prompt_fragment_id: $promptFragmentId'
          : 'prompt_fragment_id: null',
    );
    return buffer.toString();
  }
}

class StateTransitionCommand
    implements Command<StateTransitionInput, StateTransitionOutput> {
  @override
  final StateTransitionInput input;
  final BranchProvider branchProvider;
  final GitCommandRunner gitCommandRunner;
  final Assets? _assets;

  StateTransitionCommand(
    this.input, {
    BranchProvider? branchProvider,
    GitCommandRunner? gitCommandRunner,
    Assets? assets,
  }) : branchProvider = branchProvider ?? _defaultBranchProvider,
       gitCommandRunner = gitCommandRunner ?? _defaultGitCommandRunner,
       _assets = assets;

  @override
  String? validate() => null;

  @override
  Future<StateTransitionOutput> execute() async {
    if (input.event == null || input.event!.trim().isEmpty) {
      throw CommandException(
        code: 'MISSING_EVENT',
        message: 'Missing required flag --event for state transition',
        exitCode: ExitCode.validationFailed,
      );
    }

    final projectRoot = getProjectRoot(input.workingDirectory) ?? input.workingDirectory;
    final contractPath = _assets != null
        ? _assets.path('fsm/transition_contract.yaml')
        : p.join(
        projectRoot,
            'assets',
            'fsm',
            'transition_contract.yaml',
          );
    final contract = parseFsmContract(File(contractPath).readAsStringSync());

    final current = input.currentState != null
        ? FsmState.fromValue(input.currentState!.trim().toUpperCase())
        : _loadCurrentState(input.workingDirectory);
    final event = FsmEvent.fromValue(input.event!.trim().toLowerCase());

    final transition = contract.transitionFor(current, event);
    if (!transition.allowed) {
      return StateTransitionOutput(
        allowed: false,
        currentState: current.value,
        event: event.value,
        nextState: null,
        operationsExecuted: const ['validate_transition'],
        promptFragmentId: null,
        requiredRole: null,
        requiredInstructions: null,
        message: transition.reason ?? 'Illegal transition',
        code: ExitCode.invalidUsage,
      );
    }

    final branch = await branchProvider(input.workingDirectory);

    final precheckResult = await _validatePreconditions(
      transition,
      input.workingDirectory,
      branch: branch,
      inputIssue: input.issue,
    );
    if (precheckResult != null) {
      return StateTransitionOutput(
        allowed: false,
        currentState: current.value,
        event: event.value,
        nextState: null,
        operationsExecuted: const ['validate_transition', 'validate_prechecks'],
        promptFragmentId: null,
        requiredRole: null,
        requiredInstructions: null,
        message: precheckResult,
        code: ExitCode.validationFailed,
      );
    }

    final boundaryCommitResult = await _executeBoundaryCommit(
      transition,
      input.workingDirectory,
      branch: branch,
      issue: _resolveIssue(input.workingDirectory, input.issue),
    );
    if (boundaryCommitResult.errorMessage != null) {
      return StateTransitionOutput(
        allowed: false,
        currentState: current.value,
        event: event.value,
        nextState: null,
        operationsExecuted: const ['validate_transition', 'validate_prechecks'],
        promptFragmentId: null,
        requiredRole: null,
        requiredInstructions: null,
        message: boundaryCommitResult.errorMessage!,
        code: ExitCode.genericError,
      );
    }

    final operations = transition.operations;
    final promptId = operations?.promptFragmentId;
    final prompt = promptId != null ? contract.promptFragments[promptId] : null;

    // Execute CLI-side effects
    final executor = EffectExecutor(
      workingDirectory: input.workingDirectory,
      assets: _assets,
    );
    final executedEffects = executor.executeAll(
      effects: operations?.effects ?? const <String>[],
      newState: transition.to?.value ?? current.value,
      issue: input.issue,
      promptFragmentId: promptId,
    );

    return StateTransitionOutput(
      allowed: true,
      currentState: current.value,
      event: event.value,
      nextState: transition.to?.value,
      operationsExecuted: <String>[
        'validate_transition',
        'validate_prechecks',
        ...boundaryCommitResult.operationsExecuted,
        ...executedEffects,
      ],
      promptFragmentId: promptId,
      requiredRole: prompt?.role,
      requiredInstructions: prompt?.instructions,
      message:
          'Transition ${current.value} --${event.value}--> ${transition.to?.value}',
      code: ExitCode.ok,
    );
  }

  Future<String?> _validatePreconditions(
    FsmTransition transition,
    String workingDirectory, {
    required String branch,
    String? inputIssue,
  }) async {
    final prechecks = transition.operations?.prechecks ?? const <String>[];
    final issueSelected =
        _isIssueSelected(workingDirectory) ||
        (inputIssue != null && inputIssue.trim().isNotEmpty);

    if ((prechecks.contains('issue_selected') ||
            prechecks.contains('issue_selected_or_created')) &&
        !issueSelected) {
      return 'ERROR_PRECONDITION_ISSUE_FIRST: Create/select issue before commitment actions';
    }

    if (prechecks.contains('feature_branch_selected') &&
        (branch == 'main' || branch == 'master' || branch.isEmpty)) {
      return 'ERROR_PRECONDITION_BRANCH_POLICY: Use issue-linked feature branch, not main';
    }

    if (prechecks.contains('diagnosis_exists') &&
        !_analysisDiagnosisExists(branch, workingDirectory)) {
      return 'ERROR_PRECONDITION_DIAGNOSIS_MISSING: diagnosis.md missing for current issue branch';
    }

    if (prechecks.contains('index_exists') &&
        !_analysisIndexExists(branch, workingDirectory)) {
      return 'ERROR_PRECONDITION_ANALYZE_INDEX_MISSING: index.md missing for current issue branch';
    }

    if (prechecks.contains('confirmations_exists') &&
        !_analysisConfirmationsExists(branch, workingDirectory)) {
      return 'ERROR_PRECONDITION_CONFIRMATIONS_MISSING: confirmations.md missing for current issue branch';
    }

    if (prechecks.contains('plan_approved') &&
        !_planExists(branch, workingDirectory)) {
      return 'ERROR_PRECONDITION_PLAN_MISSING: plan.md missing for current issue branch';
    }

    if (prechecks.contains('pre_pr_inspection_approved')) {
      final report = _prePrInspectionReport(branch, workingDirectory);
      if (!report.exists || report.verdict == null) {
        return 'ERROR_PRECONDITION_PRE_PR_INSPECTION_MISSING: pre_pr_inspection.md missing or verdict not found for current issue branch';
      }
      if (!report.hasRequiredPassStructure) {
        return 'ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID: pre_pr_inspection.md must contain Consistency, Completeness, and Traceability sections with PASS, FAIL, or WARN checks';
      }
      if (report.hasMissingRequiredCitations) {
        return 'ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID: FAIL checks in pre_pr_inspection.md must include repo-relative file:line citations';
      }
      if (report.verdict == 'APPROVED' && report.hasFailChecks) {
        return 'ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID: pre_pr_inspection.md cannot declare APPROVED while any pass contains FAIL checks';
      }
      if (report.verdict != 'APPROVED') {
        return 'ERROR_PRECONDITION_PRE_PR_INSPECTION_BLOCKED: pre_pr_inspection.md verdict is ${report.verdict}';
      }
    }

    return null;
  }

  Future<_BoundaryCommitResult> _executeBoundaryCommit(
    FsmTransition transition,
    String workingDirectory, {
    required String branch,
    String? issue,
  }) async {
    final policy = transition.operations?.commitPolicy ?? 'none';
    final spec = _boundaryCommitSpec(policy, branch: branch, issue: issue);
    if (spec == null) {
      return const _BoundaryCommitResult.success();
    }

    if (branch.isEmpty || branch == 'main' || branch == 'master') {
      return _BoundaryCommitResult.failure(
        'ERROR_BOUNDARY_COMMIT_BRANCH_POLICY: Cannot create ${spec.label} commit without an issue-linked feature branch',
      );
    }

    final stageResult = await gitCommandRunner(workingDirectory, [
      'add',
      '--',
      spec.path,
    ]);
    if (stageResult.exitCode != 0) {
      return _BoundaryCommitResult.failure(
        'ERROR_BOUNDARY_COMMIT_FAILED: Failed to stage ${spec.label} artifacts: ${_gitError(stageResult)}',
      );
    }

    final commitResult = await gitCommandRunner(workingDirectory, [
      'commit',
      '-m',
      spec.message,
      '--only',
      '--',
      spec.path,
    ]);
    if (commitResult.exitCode != 0) {
      return _BoundaryCommitResult.failure(
        'ERROR_BOUNDARY_COMMIT_FAILED: Failed to create ${spec.label} commit: ${_gitError(commitResult)}',
      );
    }

    return const _BoundaryCommitResult.success(
      operationsExecuted: ['create_boundary_commit'],
    );
  }

  _BoundaryCommitSpec? _boundaryCommitSpec(
    String policy, {
    required String branch,
    String? issue,
  }) {
    switch (policy) {
      case 'commit_analysis_boundary':
        return _BoundaryCommitSpec(
          label: 'analysis boundary',
          path: p.posix.join('cleanrooms', branch, 'analyze'),
          message: _boundaryCommitMessage('analysis', issue),
        );
      case 'commit_plan_boundary':
        return _BoundaryCommitSpec(
          label: 'plan boundary',
          path: p.posix.join('cleanrooms', branch, 'plan.md'),
          message: _boundaryCommitMessage('plan', issue),
        );
      default:
        return null;
    }
  }

  String _boundaryCommitMessage(String boundary, String? issue) {
    final suffix = issue != null && issue.trim().isNotEmpty
        ? ' for #$issue'
        : '';
    return 'approve $boundary boundary$suffix';
  }

  String _gitError(ProcessResult result) {
    final stderr = result.stderr.toString().trim();
    if (stderr.isNotEmpty) {
      return stderr;
    }

    final stdout = result.stdout.toString().trim();
    if (stdout.isNotEmpty) {
      return stdout;
    }

    return 'git exited with code ${result.exitCode}';
  }

  bool _analysisDiagnosisExists(String branch, String workingDirectory) {
    if (branch.isEmpty) return false;
    final diagnosisPath = p.join(
      workingDirectory,
      'cleanrooms',
      branch,
      'analyze',
      'diagnosis.md',
    );
    return File(diagnosisPath).existsSync();
  }

  bool _analysisIndexExists(String branch, String workingDirectory) {
    if (branch.isEmpty) return false;
    final indexPath = p.join(
      workingDirectory,
      'cleanrooms',
      branch,
      'analyze',
      'index.md',
    );
    return File(indexPath).existsSync();
  }

  bool _analysisConfirmationsExists(String branch, String workingDirectory) {
    if (branch.isEmpty) return false;
    final confirmationsPath = p.join(
      workingDirectory,
      'cleanrooms',
      branch,
      'analyze',
      'confirmations.md',
    );
    return File(confirmationsPath).existsSync();
  }

  _PrePrInspectionReport _prePrInspectionReport(
    String branch,
    String workingDirectory,
  ) {
    if (branch.isEmpty) {
      return const _PrePrInspectionReport(
        exists: false,
        verdict: null,
        checksByPass: <String, List<_PrePrInspectionCheck>>{},
      );
    }

    final projectRoot = getProjectRoot(workingDirectory) ?? workingDirectory;
    final reportPath = p.join(
      projectRoot,
      'cleanrooms',
      branch,
      'pre_pr_inspection.md',
    );
    final file = File(reportPath);
    if (!file.existsSync()) {
      return const _PrePrInspectionReport(
        exists: false,
        verdict: null,
        checksByPass: <String, List<_PrePrInspectionCheck>>{},
      );
    }

    final content = file.readAsStringSync();

    final match = RegExp(
      r'^verdict:\s*([A-Za-z_\-]+)\s*$',
      multiLine: true,
    ).firstMatch(content);

    final checksByPass = <String, List<_PrePrInspectionCheck>>{};
    String? currentPass;
    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.startsWith('## ')) {
        currentPass = _normalizeInspectionPass(line.substring(3).trim());
        if (currentPass != null) {
          checksByPass.putIfAbsent(
            currentPass,
            () => <_PrePrInspectionCheck>[],
          );
        }
        continue;
      }

      final checkMatch = _inspectionCheckPattern.firstMatch(line);
      if (checkMatch != null && currentPass != null) {
        checksByPass[currentPass]!.add(
          _PrePrInspectionCheck(
            status: checkMatch.group(1)!.toUpperCase(),
            detail: checkMatch.group(2)!.trim(),
          ),
        );
      }
    }

    return _PrePrInspectionReport(
      exists: true,
      verdict: match?.group(1)?.trim().toUpperCase(),
      checksByPass: checksByPass,
    );
  }

  String? _normalizeInspectionPass(String heading) {
    final normalizedHeading = heading.toLowerCase();
    for (final pass in _requiredInspectionPasses) {
      if (normalizedHeading.contains(pass.toLowerCase())) {
        return pass;
      }
    }
    return null;
  }

  bool _planExists(String branch, String workingDirectory) {
    if (branch.isEmpty) return false;
    final planPath = p.join(workingDirectory, 'cleanrooms', branch, 'plan.md');
    return File(planPath).existsSync();
  }

  String? _resolveIssue(String workingDirectory, String? inputIssue) {
    if (inputIssue != null && inputIssue.trim().isNotEmpty) {
      return inputIssue.trim();
    }
    return InquiryState.load(workingDirectory).issue;
  }

  bool _isIssueSelected(String workingDirectory) {
    return InquiryState.load(workingDirectory).issue != null;
  }

  FsmState _loadCurrentState(String workingDirectory) {
    final phase = InquiryState.load(workingDirectory).state;
    if (phase.trim().isEmpty) return FsmState.idle;
    return FsmState.fromValue(phase.trim().toUpperCase());
  }

  static Future<String> _defaultBranchProvider(String workingDirectory) async {
    final result = await Process.run('git', [
      'rev-parse',
      '--abbrev-ref',
      'HEAD',
    ], workingDirectory: workingDirectory);
    if (result.exitCode != 0) return '';
    return result.stdout.toString().trim();
  }

  static Future<ProcessResult> _defaultGitCommandRunner(
    String workingDirectory,
    List<String> arguments,
  ) {
    return Process.run('git', arguments, workingDirectory: workingDirectory);
  }
}
