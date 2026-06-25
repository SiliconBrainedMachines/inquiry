import 'dart:io';

import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/hosts/agent_builder.dart';
import 'package:inquiry_cli/hosts/claude_adapter.dart';
import 'package:inquiry_cli/hosts/copilot_adapter.dart';
import 'package:inquiry_cli/hosts/opencode_adapter.dart';

/// Returns the frontmatter block (between the first two `---` markers).
String _frontmatter(String md) {
  final lines = md.split('\n');
  expect(lines.first.trim(), '---', reason: 'must open with frontmatter');
  final end = lines.indexOf('---', 1);
  expect(end, greaterThan(0), reason: 'frontmatter must be closed');
  return lines.sublist(1, end).join('\n');
}

/// Returns the body (everything after the closing frontmatter `---`).
String _body(String md) {
  final lines = md.split('\n');
  final end = lines.indexOf('---', 1);
  expect(end, greaterThan(0), reason: 'frontmatter must be closed');
  return lines.sublist(end + 1).join('\n');
}

void main() {
  late AgentBuilder builder;

  setUp(() {
    builder = AgentBuilder(Assets(root: Directory.current.path));
  });

  group('AgentBuilder — single body + per-host frontmatter', () {
    test('there is a single shared body asset (no per-host body duplication)', () {
      final body = Assets(
        root: Directory.current.path,
      ).loadString('agents/inquiry.body.md');
      expect(body, contains('Inquiry Scheduler'),
          reason: 'body asset holds the firmware');
      expect(body, contains('{{INIT_HINT}}'),
          reason: 'host-specific init line is a placeholder, not duplicated');
    });

    test('copilot build carries Copilot frontmatter (name + tools)', () {
      final fm = _frontmatter(builder.build(CopilotAdapter()));
      expect(fm, contains('name: inquiry'));
      expect(fm, contains('tools:'));
    });

    test('opencode build carries OpenCode frontmatter (mode: primary; no name/tools)', () {
      final fm = _frontmatter(builder.build(OpenCodeAdapter()));
      expect(fm, contains('mode: primary'));
      expect(fm, isNot(contains('name: inquiry')));
      expect(fm, isNot(contains('tools:')));
    });

    test('rendered bodies are identical EXCEPT the host-specific lines (init hint + dispatch tool)', () {
      // Two lines carry per-host substitutions: the init hint and the
      // sub-agent dispatch tool name ({{DISPATCH_TOOL}}: agent/task/Agent).
      List<String> withoutHostSpecific(String md) => _body(md)
          .split('\n')
          .where((l) => !l.contains('the CLI is not installed'))
          .where((l) => !l.contains('**Dispatch** that sub-agent'))
          .toList();
      expect(
        withoutHostSpecific(builder.build(CopilotAdapter())),
        equals(withoutHostSpecific(builder.build(OpenCodeAdapter()))),
        reason: 'single source of truth: bodies share everything but the per-host lines',
      );
    });

    test('host-specific init hint is substituted; no placeholder leaks', () {
      final c = builder.build(CopilotAdapter());
      final o = builder.build(OpenCodeAdapter());
      expect(c, isNot(contains('{{')));
      expect(o, isNot(contains('{{')));
      expect(c, contains('Inquiry: Init'), reason: 'Copilot/VS Code hint');
      expect(o, contains('Run `iq init`'), reason: 'CLI hint');
    });

    test('dispatch tool name is substituted per host (#276)', () {
      // OpenCode has no `agent` tool — it is `task`; Claude uses `Agent`.
      expect(builder.build(CopilotAdapter()), contains('use the `agent` tool'));
      expect(builder.build(OpenCodeAdapter()), contains('use the `task` tool'));
      expect(builder.build(ClaudeAdapter()), contains('use the `Agent` tool'));
      for (final a in [CopilotAdapter(), OpenCodeAdapter(), ClaudeAdapter()]) {
        expect(builder.build(a), isNot(contains('{{DISPATCH_TOOL}}')));
      }
    });

    test('exact-literal rule (#240) is present for BOTH hosts (drift fixed)', () {
      for (final md in [
        builder.build(CopilotAdapter()),
        builder.build(OpenCodeAdapter()),
      ]) {
        expect(md, contains('If the user requests an exact literal response'));
        expect(md, contains('output only that literal'));
      }
    });

    test('assembled firmware keeps scheduler identity + core CLI contract', () {
      final md = builder.build(OpenCodeAdapter());
      expect(md, startsWith('---\n'));
      expect(md, contains('Inquiry Scheduler'));
      expect(md, contains('iq fsm state'));
      expect(md, contains('iq ape prompt'));
      expect(md, contains('iq ape transition'));
    });
  });
}
