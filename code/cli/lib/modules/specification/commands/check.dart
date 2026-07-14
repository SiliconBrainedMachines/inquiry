/// `iq specification check [--slug <slug>]` — runs the `specification_ready`
/// gate over the active requisition's `specification.md`
/// (`.inquiry/specification.yaml`; `--slug` overrides).
///
/// The CLI runs the gate (Constitution I); the brain fixes exactly what it
/// reports. The specification phase is outside the dev FSM, so this is a
/// standalone check rather than an `iq fsm transition` event — but it plays the
/// same role: the artifact does not leave the QA phase until it exits 0.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../slug.dart';
import '../specification_gate.dart';
import '../workspace.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class SpecificationCheckInput extends Input {
  /// The requisition workspace override; `null` → the active requisition
  /// recorded in `.inquiry/specification.yaml`.
  final String? slug;

  SpecificationCheckInput({this.slug});

  static final List<CliParam> params = [
    CliParam.string(
      'slug',
      description: 'Requisition to check; defaults to the active one',
    ),
  ];

  factory SpecificationCheckInput.fromCliRequest(CliRequest req) =>
      SpecificationCheckInput(slug: optionalSlug(req.flagString('slug')));

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() => {'slug': slug};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class SpecificationCheckOutput extends Output {
  final String message;
  final bool ready;

  SpecificationCheckOutput({required this.message, required this.ready});

  @override
  Map<String, dynamic> toJson() => {'ready': ready, 'message': message};

  @override
  int get exitCode => ready ? ExitCode.ok : ExitCode.validationFailed;

  @override
  String? toText() => message;
}

// ─── Command ────────────────────────────────────────────────────────────────

class SpecificationCheckCommand
    implements Command<SpecificationCheckInput, SpecificationCheckOutput> {
  @override
  final SpecificationCheckInput input;

  final String workingDirectory;
  final SpecificationGate gate;

  SpecificationCheckCommand(
    this.input, {
    required this.workingDirectory,
    SpecificationGate? gate,
  }) : gate = gate ?? SpecificationGate();

  String? get _dir => resolveRequisitionDir(workingDirectory, input.slug);

  File? get _specFile {
    final d = _dir;
    return d == null ? null : File(p.join(d, 'specification.md'));
  }

  /// Display name for messages: the explicit slug, else the resolved folder.
  String get _name {
    final d = _dir;
    return input.slug ?? (d != null ? p.basename(d) : 'active requisition');
  }

  @override
  String? validate() {
    final spec = _specFile;
    if (spec == null || !spec.existsSync()) {
      return 'No specification found — run `iq specification new <slug>` first, '
          'or point at one with --slug <slug>.';
    }
    return null;
  }

  @override
  Future<SpecificationCheckOutput> execute() async {
    final result = gate.evaluate(
      _specFile!.readAsStringSync(),
      issues: _issueBodies(),
    );

    if (result.passed) {
      return SpecificationCheckOutput(
        ready: true,
        message: 'specification "$_name" is ready — '
            'every rule of the specification_ready gate passes.',
      );
    }

    final lines = <String>[
      'specification "$_name" is NOT ready — fix these and re-run:',
      for (final v in result.violations) '  - ${v.code}: ${v.message}',
    ];
    return SpecificationCheckOutput(ready: false, message: lines.join('\n'));
  }

  /// The contents of the `issue-*.md` files derived under the slug's workspace —
  /// the gate reads them to verify AC → issue traceability.
  List<String> _issueBodies() {
    final d = _dir;
    if (d == null) return const [];
    final dir = Directory(d);
    if (!dir.existsSync()) return const [];
    return dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final name = p.basename(f.path);
          return name.startsWith('issue-') && name.endsWith('.md');
        })
        .map((f) => f.readAsStringSync())
        .toList();
  }
}
