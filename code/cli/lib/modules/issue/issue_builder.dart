import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import '../../templates/template_resolver.dart';
import 'commands/new.dart';
import 'commands/publish.dart';

/// Registers the `issue` module — "issue as code".
///
/// `iq issue new <slug> <name>` scaffolds `requisitions/<slug>/issue-<name>.md`
/// from the single-source bilingual template (inheriting the spec's `iq:lang`),
/// and `iq issue publish <slug> <name> [--plan|--apply]` turns that `.md` into a
/// GitHub issue via `gh` (Terraform-style: `--plan` previews, `--apply` creates).
void buildIssueModule(ModuleBuilder m, {required Assets assets}) {
  final resolver = TemplateResolver(assets);

  m.command<IssueNewInput, IssueNewOutput>(
    'new <slug> <name>',
    (req) => IssueNewCommand(
      IssueNewInput.fromCliRequest(req),
      resolver: resolver,
      workingDirectory: Directory.current.path,
    ),
    description:
        'Scaffold requisitions/<slug>/issue-<name>.md (issue as code). '
        '--repo owner/repo pre-fills the target; language inherits from the spec.',
  );

  m.command<IssuePublishInput, IssuePublishOutput>(
    'publish <slug> <name>',
    (req) => IssuePublishCommand(
      IssuePublishInput.fromCliRequest(req),
      workingDirectory: Directory.current.path,
    ),
    description:
        'Create the GitHub issue from issue-<name>.md via gh. '
        '--plan (default) previews the command; --apply runs it.',
  );
}
