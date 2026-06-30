/// `iq specification check <slug>` — runs the `specification_ready` gate over
/// `requisitions/<slug>/specification.md`.
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

// ─── Input ──────────────────────────────────────────────────────────────────

class SpecificationCheckInput extends Input {
  final String slug;

  SpecificationCheckInput({required this.slug});

  factory SpecificationCheckInput.fromCliRequest(CliRequest req) =>
      SpecificationCheckInput(slug: normalizeSlug(req.param('slug') ?? ''));

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

  String get _dir => p.join(workingDirectory, 'requisitions', input.slug);

  File get _specFile => File(p.join(_dir, 'specification.md'));

  @override
  String? validate() {
    if (input.slug.isEmpty) {
      return 'A <slug> is required: iq specification check <slug>';
    }
    if (!_specFile.existsSync()) {
      return 'No specification found at requisitions/${input.slug}/'
          'specification.md — run `iq specification new ${input.slug}` first.';
    }
    return null;
  }

  @override
  Future<SpecificationCheckOutput> execute() async {
    final result = gate.evaluate(
      _specFile.readAsStringSync(),
      issues: _issueBodies(),
    );

    if (result.passed) {
      return SpecificationCheckOutput(
        ready: true,
        message: 'specification "${input.slug}" is ready — '
            'every rule of the specification_ready gate passes.',
      );
    }

    final lines = <String>[
      'specification "${input.slug}" is NOT ready — fix these and re-run:',
      for (final v in result.violations) '  - ${v.code}: ${v.message}',
    ];
    return SpecificationCheckOutput(ready: false, message: lines.join('\n'));
  }

  /// The contents of the `issue-*.md` files derived under the slug's workspace —
  /// the gate reads them to verify AC → issue traceability.
  List<String> _issueBodies() {
    final dir = Directory(_dir);
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
