import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import '../../templates/template_resolver.dart';
import 'commands/check.dart';
import 'commands/new.dart';

/// Registers the `specification` module — the QA-facing specification phase.
///
/// `iq specification new <slug> [--lang <lang>]` scaffolds the QA workspace
/// `requisitions/<slug>/` with `requisition.md` + `specification.md` from the
/// single-source templates (Constitution I: the CLI is the hands).
void buildSpecificationModule(ModuleBuilder m, {required Assets assets}) {
  final resolver = TemplateResolver(assets);

  m.command<SpecificationNewInput, SpecificationNewOutput>(
    'new <slug>',
    (req) => SpecificationNewCommand(
      SpecificationNewInput.fromCliRequest(req),
      resolver: resolver,
      workingDirectory: Directory.current.path,
    ),
    description:
        'Scaffold a QA specification workspace requisitions/<slug>/ '
        '(requisition.md + specification.md). --lang <en|es> (default: en)',
  );

  m.command<SpecificationCheckInput, SpecificationCheckOutput>(
    'check',
    (req) => SpecificationCheckCommand(
      SpecificationCheckInput.fromCliRequest(req),
      workingDirectory: Directory.current.path,
    ),
    description:
        'Run the specification_ready gate over the active requisition '
        '(or --slug <slug>) — exits 0 only when the spec is healthy.',
  );
}
