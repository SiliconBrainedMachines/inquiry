/// `iq ape prompt <name>` — assembles a sub-agent prompt from YAML + FSM state.
///
/// Reads the YAML definition from `assets/apes/<name>.yaml`,
/// verifies the sub-agent is active in the current FSM state,
/// and returns the assembled prompt (base + optional sub-state).
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../fsm_contract.dart';
import '../../../src/cycle_context.dart';
import '../../../src/git_utils.dart';
import '../ape_definition.dart';
import '../instruction_prompt_loader.dart';
import '../inquiry_state.dart';
import '../operational_contract.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class ApePromptInput extends Input {
  final String? name;
  final String? subState;
  final String workingDirectory;

  ApePromptInput({
    required this.name,
    this.subState,
    required this.workingDirectory,
  });

  factory ApePromptInput.fromCliRequest(CliRequest req) {
    return ApePromptInput(
      name: req.flagString('name', aliases: const ['n']),
      subState: req.flagString('state', aliases: const ['s']),
      workingDirectory: Directory.current.path,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (subState != null) 'subState': subState,
    'workingDirectory': workingDirectory,
  };
}

// ─── Output ─────────────────────────────────────────────────────────────────

class ApePromptOutput extends Output {
  final String apeName;
  final String fsmState;
  final String? subState;
  final String prompt;

  ApePromptOutput({
    required this.apeName,
    required this.fsmState,
    this.subState,
    required this.prompt,
  });

  @override
  Map<String, dynamic> toJson() => {
    'ape': apeName,
    'fsm_state': fsmState,
    if (subState != null) 'sub_state': subState,
    'prompt': prompt,
  };

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => prompt;
}

// ─── Command ────────────────────────────────────────────────────────────────

/// Assembles a sub-agent prompt from its YAML definition + current FSM state.
class ApePromptCommand implements Command<ApePromptInput, ApePromptOutput> {
  @override
  final ApePromptInput input;
  final Assets? _assets;

  ApePromptCommand(this.input, {Assets? assets}) : _assets = assets;

  /// Maps FSM states to their active sub-agent names.
  static const _stateApes = <FsmState, List<String>>{
    FsmState.idle: ['dewey'],
    FsmState.analyze: ['socrates'],
    FsmState.plan: ['descartes'],
    FsmState.execute: ['basho'],
    FsmState.end: ['basho'],
    FsmState.evolution: ['darwin'],
  };

  @override
  String? validate() => null;

  late final CycleContext? _cycleContext = _tryResolveCycleContext();

  @override
  Future<ApePromptOutput> execute() async {
    if (input.name == null || input.name!.trim().isEmpty) {
      throw CommandException(
        code: 'MISSING_NAME',
        message:
            'Missing required flag --name. Usage: iq ape prompt --name <name>',
        exitCode: ExitCode.validationFailed,
      );
    }
    final inquiry = InquiryState.load(input.workingDirectory);
    final currentState = FsmState.fromValue(inquiry.state.trim().toUpperCase());

    // Verify the APE exists
    final yamlPath = _resolveApePath(input.name!);
    final yamlFile = File(yamlPath);
    if (!yamlFile.existsSync()) {
      throw CommandException(
        code: 'APE_NOT_FOUND',
        message: 'No definition found for "${input.name!}" at $yamlPath',
        exitCode: ExitCode.notFound,
      );
    }

    // Verify the APE is active in the current FSM state
    final activeApes = _stateApes[currentState] ?? [];
    if (!activeApes.contains(input.name!)) {
      throw CommandException(
        code: 'APE_NOT_ACTIVE',
        message:
            '"${input.name!}" is not active in state '
            '${currentState.value}. Active APEs: ${activeApes.join(', ')}',
        exitCode: ExitCode.conflict,
      );
    }

    // Resolve sub-state: explicit flag > state.yaml > null
    final resolvedSubState = input.subState ?? inquiry.apeState;

    final operationalContract = OperationalContractLoader(
      workingDirectory: input.workingDirectory,
      assets: _assets,
    ).load(currentState);
    final transitionInstructions = _resolveTransitionInstructions(inquiry);
    final context = _resolveContext(
      input.name!,
      resolvedSubState,
      inquiry: inquiry,
      operationalContract: operationalContract,
    );

    // Parse and assemble
    final definition = ApeDefinition.parse(yamlFile.readAsStringSync());
    final prompt = definition.assemblePrompt(
      stateName: resolvedSubState,
      transitionInstructions: transitionInstructions,
      operationalContract: operationalContract.render(),
      context: context,
    );

    return ApePromptOutput(
      apeName: input.name!,
      fsmState: currentState.value,
      subState: resolvedSubState,
      prompt: prompt,
    );
  }

  String? _resolveTransitionInstructions(InquiryState inquiry) {
    final promptFragmentId = inquiry.promptFragmentId;
    if (promptFragmentId == null || promptFragmentId.trim().isEmpty) {
      return null;
    }

    final contractPath = _assets != null
        ? _assets.path('fsm/transition_contract.yaml')
        : p.join(
            _resolvedProjectRoot,
            'assets',
            'fsm',
            'transition_contract.yaml',
          );
    final contract = parseFsmContract(File(contractPath).readAsStringSync());
    final fragment = contract.promptFragments[promptFragmentId];
    if (fragment == null) {
      throw CommandException(
        code: 'PROMPT_FRAGMENT_NOT_FOUND',
        message: 'No prompt fragment found for "$promptFragmentId"',
        exitCode: ExitCode.notFound,
      );
    }
    if (fragment.instructions.isEmpty) {
      return null;
    }

    final assets = _assets ?? Assets(root: input.workingDirectory);
    final loader = InstructionPromptLoader(assets: assets);
    return loader.loadMany(fragment.instructions);
  }

  /// Resolves dynamic context paths per APE and FSM state.
  Map<String, String>? _resolveContext(
    String apeName,
    String? subState, {
    required InquiryState inquiry,
    required OperationalContract operationalContract,
  }) {
    final context = <String, String>{};

    final stateOwnedContext = operationalContract.inquiryContextFor(
      apeName: apeName,
      subState: subState,
    );
    if (stateOwnedContext != null) {
      context.addAll(stateOwnedContext);
    }

    final runtimeContext = _resolveRuntimeContext(apeName, inquiry);
    if (runtimeContext != null) {
      context.addAll(runtimeContext);
    }

    return context.isEmpty ? null : context;
  }

  Map<String, String>? _resolveRuntimeContext(
    String apeName,
    InquiryState inquiry,
  ) {
    final cycleContext = _cycleContext;
    final branch = cycleContext?.branch;
    if (cycleContext == null || branch == null) return null;
    final currentState = FsmState.fromValue(inquiry.state.trim().toUpperCase());

    final cleanroomRoot = 'cleanrooms/$branch/';
    final analyzeDir = 'cleanrooms/$branch/analyze/';
    final taskId = (inquiry.issue != null && inquiry.issue!.trim().isNotEmpty)
        ? inquiry.issue!.trim()
        : branch;

    final baseContext = <String, String>{
      'project_root': cycleContext.projectRoot,
      'task_id': taskId,
    };

    switch (apeName) {
      case 'socrates':
        return {
          ...baseContext,
          ..._contextPolicy(
            contextPolicy: 'progressive-disclosure',
            authorityMode: 'build-authoritative-analysis',
            upfrontContext: [
              '${cleanroomRoot}issue.md',
              '${analyzeDir}index.md',
            ],
            retrievalContext: [
              '${analyzeDir}index.md',
              '${analyzeDir}confirmations.md',
              cycleContext.projectRoot,
            ],
            deferredContext: const [
              'broad repository rereads not justified by the active uncertainty',
            ],
            authoritativeHandoff: '${analyzeDir}diagnosis.md',
            authorityRule:
                'diagnosis.md becomes the authoritative handoff to PLAN once written',
          ),
          'input_artifacts': _yamlList([
            '${cleanroomRoot}issue.md',
            '${analyzeDir}index.md',
          ]),
          'expected_outputs': _yamlList([
            '${analyzeDir}confirmations.md',
            '${analyzeDir}diagnosis.md',
          ]),
          'editable_surfaces': _yamlList([analyzeDir]),
          'read_only_surfaces': _yamlList(['${cleanroomRoot}issue.md']),
          'validation_commands': _yamlList(const []),
          'done_criteria': _yamlList([
            '${analyzeDir}diagnosis.md is written',
            '${analyzeDir}confirmations.md captures the bounded analysis corpus',
          ]),
          'output_dir': analyzeDir,
          'index_file': '${analyzeDir}index.md',
          'confirmations_doc': '${analyzeDir}confirmations.md',
          'doc_protocol': 'doc-write',
        };
      case 'descartes':
        return {
          ...baseContext,
          ..._contextPolicy(
            contextPolicy: 'authoritative-handoff',
            authorityMode: 'trust-diagnosis-first',
            upfrontContext: ['${analyzeDir}diagnosis.md'],
            retrievalContext: [
              '${analyzeDir}index.md',
              cycleContext.projectRoot,
            ],
            deferredContext: const [
              'reconstructing ANALYZE from broad rereads when diagnosis.md is already authoritative',
            ],
            authoritativeHandoff: '${analyzeDir}diagnosis.md',
            authorityRule:
                'trust diagnosis.md as the planning baseline unless a concrete gap requires targeted retrieval',
          ),
          'input_artifacts': _yamlList(['${analyzeDir}diagnosis.md']),
          'expected_outputs': _yamlList(['${cleanroomRoot}plan.md']),
          'editable_surfaces': _yamlList(['${cleanroomRoot}plan.md']),
          'read_only_surfaces': _yamlList(['${analyzeDir}diagnosis.md']),
          'validation_commands': _yamlList(const []),
          'done_criteria': _yamlList([
            '${cleanroomRoot}plan.md defines ordered phases',
            '${cleanroomRoot}plan.md includes verification criteria for each phase',
          ]),
          'analysis_input': '${analyzeDir}diagnosis.md',
          'output_dir': cleanroomRoot,
          'plan_file': '${cleanroomRoot}plan.md',
          'doc_protocol': 'doc-read',
        };
      case 'basho':
        final sensorContext = currentState == FsmState.end
            ? _sensorContext(
                sensorPolicy: 'minimum-phase-stack',
                minimumSensorStack: const [
                  'pre_pr',
                  'ci_required',
                  'runtime',
                  'inferential_optional',
                ],
                blockingSensorStack: const ['pre_pr', 'runtime'],
                advisorySensorStack: const ['inferential_optional'],
                sensorGate: 'end-pre-pr-inspection',
                sensorAuthorityRule:
                    'ci_required remains merge-authoritative after PR creation even when the local END gate is green',
              )
            : _sensorContext(
                sensorPolicy: 'minimum-phase-stack',
                minimumSensorStack: const [
                  'local_fast',
                  'pre_transition',
                  'pre_pr',
                  'runtime',
                ],
                blockingSensorStack: const [
                  'local_fast',
                  'pre_transition',
                  'runtime',
                ],
                advisorySensorStack: const ['inferential_optional'],
                sensorGate: 'handoff-to-end',
                sensorAuthorityRule:
                    'pre_pr evidence must be complete before END handoff even when phase-local checks are green',
              );
        return {
          ...baseContext,
          ..._contextPolicy(
            contextPolicy: 'authoritative-handoff',
            authorityMode: 'trust-plan-first',
            upfrontContext: ['${cleanroomRoot}plan.md'],
            retrievalContext: [cycleContext.projectRoot, cleanroomRoot],
            deferredContext: const [
              're-reading broad analysis artifacts when plan.md already defines the bounded execution contract',
            ],
            authoritativeHandoff: '${cleanroomRoot}plan.md',
            authorityRule:
                'trust plan.md as the execution baseline unless implementation hits a concrete ambiguity that requires targeted retrieval',
          ),
          ...sensorContext,
          'input_artifacts': _yamlList(['${cleanroomRoot}plan.md']),
          'expected_outputs': _yamlList([
            cycleContext.projectRoot,
            cleanroomRoot,
          ]),
          'editable_surfaces': _yamlList([
            cycleContext.projectRoot,
            cleanroomRoot,
          ]),
          'read_only_surfaces': _yamlList(['${cleanroomRoot}plan.md']),
          'validation_commands': _yamlList(const []),
          'done_criteria': _yamlList([
            'implementation remains bounded by ${cleanroomRoot}plan.md',
            'required validations complete before END',
          ]),
          'plan_file': '${cleanroomRoot}plan.md',
          'output_dir': cleanroomRoot,
          'doc_protocol': 'doc-read',
        };
      case 'darwin':
        return {
          ...baseContext,
          'input_artifacts': _yamlList([
            '${analyzeDir}diagnosis.md',
            '${cleanroomRoot}plan.md',
            '${cleanroomRoot}retrospective.md',
            '${cleanroomRoot}mutations.md',
            '.inquiry/metrics.yaml',
            '.inquiry/metrics_snapshot.yaml',
          ]),
          'expected_outputs': _yamlList([cleanroomRoot]),
          'editable_surfaces': _yamlList([
            '${cleanroomRoot}mutations.md',
            cleanroomRoot,
          ]),
          'read_only_surfaces': _yamlList([
            '${analyzeDir}diagnosis.md',
            '${cleanroomRoot}plan.md',
            '${cleanroomRoot}.iq.state.yaml',
            '.inquiry/metrics.yaml',
            '.inquiry/metrics_snapshot.yaml',
          ]),
          'validation_commands': _yamlList(const []),
          'done_criteria': _yamlList([
            'evolution findings stay grounded in cycle artifacts',
            'proposed mutations are traceable to observed evidence',
          ]),
          'analyze_dir': analyzeDir,
          'diagnosis_file': '${analyzeDir}diagnosis.md',
          'plan_file': '${cleanroomRoot}plan.md',
          'retrospective_file': '${cleanroomRoot}retrospective.md',
          'mutations_file': '${cleanroomRoot}mutations.md',
          'state_file': '${cleanroomRoot}.iq.state.yaml',
          'metrics_snapshot_file': '.inquiry/metrics_snapshot.yaml',
          'metrics_file': '.inquiry/metrics.yaml',
          'output_dir': cleanroomRoot,
        };
      default:
        return null;
    }
  }

  CycleContext? _tryResolveCycleContext() {
    try {
      return CycleContext.resolve(input.workingDirectory);
    } on CycleResolutionException {
      return null;
    }
  }

  String get _resolvedProjectRoot =>
      _cycleContext?.projectRoot ??
      getProjectRoot(input.workingDirectory) ??
      input.workingDirectory;

  String _yamlList(List<String> values) {
    if (values.isEmpty) return '[]';
    return '[${values.map(_yamlScalar).join(', ')}]';
  }

  Map<String, String> _contextPolicy({
    required String contextPolicy,
    required String authorityMode,
    required List<String> upfrontContext,
    required List<String> retrievalContext,
    required List<String> deferredContext,
    required String authoritativeHandoff,
    required String authorityRule,
  }) {
    return {
      'context_policy': contextPolicy,
      'authority_mode': authorityMode,
      'upfront_context': _yamlList(upfrontContext),
      'retrieval_context': _yamlList(retrievalContext),
      'deferred_context': _yamlList(deferredContext),
      'authoritative_handoff': authoritativeHandoff,
      'authority_rule': authorityRule,
    };
  }

  Map<String, String> _sensorContext({
    required String sensorPolicy,
    required List<String> minimumSensorStack,
    required List<String> blockingSensorStack,
    required List<String> advisorySensorStack,
    required String sensorGate,
    required String sensorAuthorityRule,
  }) {
    return {
      'sensor_policy': sensorPolicy,
      'minimum_sensor_stack': _yamlList(minimumSensorStack),
      'blocking_sensor_stack': _yamlList(blockingSensorStack),
      'advisory_sensor_stack': _yamlList(advisorySensorStack),
      'sensor_gate': sensorGate,
      'sensor_authority_rule': sensorAuthorityRule,
    };
  }

  String _yamlScalar(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  String _resolveApePath(String name) {
    if (_assets != null) {
      return _assets.path('apes/$name.yaml');
    }
    return p.join(_resolvedProjectRoot, 'assets', 'apes', '$name.yaml');
  }
}
