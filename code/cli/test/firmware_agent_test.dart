import 'dart:io';

import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/hosts/agent_builder.dart';
import 'package:inquiry_cli/hosts/copilot_adapter.dart';

void main() {
  group('inquiry firmware (assembled)', () {
    late String content;

    setUpAll(() {
      // Firmware is now assembled from the shared body + per-host frontmatter.
      content =
          AgentBuilder(Assets(root: Directory.current.path)).build(CopilotAdapter());
    });

    test('references iq fsm state', () {
      expect(content, contains('iq fsm state'));
    });

    test('references iq ape prompt', () {
      expect(content, contains('iq ape prompt'));
    });

    test('documents iq ape prompt as the exact effective prompt surface', () {
      expect(content, contains('inspect the exact effective sub-agent prompt'));
    });

    test('documents prompt assembly as identity plus operational contract plus inquiry-context', () {
      expect(
        content,
        contains('APE identity + phase-owned operational contract + inquiry-context'),
      );
    });

    test('references iq ape transition', () {
      expect(content, contains('iq ape transition'));
    });

    test('does not dispatch sub-agents by APE name', () {
      expect(content, isNot(contains('@<ape.name>')));
      expect(content, contains('Do NOT set `agentName` from `ape.name`'));
    });

    test('documents generic agent dispatch without ape-bound agentName', () {
      expect(content, contains('generic/current sub-agent path'));
      expect(content, contains('omit `agentName`'));
      expect(
        content,
        contains('independent of APE identity'),
      );
    });

    test('references iq fsm transition', () {
      expect(content, contains('iq fsm transition'));
    });

    test('does not declare one universal user-interaction rule for all states', () {
      expect(content, isNot(contains('the ONLY user interaction point')));
    });

    test('documents visible ANALYZE interaction behavior', () {
      expect(content, contains('ANALYZE must remain visible to the user'));
    });

    test('is thin: under 90 lines (excluding frontmatter)', () {
      final lines = content.split('\n');
      // Skip YAML frontmatter (between --- markers)
      var bodyStart = 0;
      if (lines.isNotEmpty && lines[0].trim() == '---') {
        for (var i = 1; i < lines.length; i++) {
          if (lines[i].trim() == '---') {
            bodyStart = i + 1;
            break;
          }
        }
      }
      final bodyLines = lines.sublist(bodyStart);
      // A trailing file newline is not a line of firmware — don't count it.
      while (bodyLines.isNotEmpty && bodyLines.last.trim().isEmpty) {
        bodyLines.removeLast();
      }
      expect(bodyLines.length, lessThan(90),
          reason: 'Firmware body should be under 90 lines, got ${bodyLines.length}');
    });

    test('does NOT contain sub-agent prompts (no monolith leakage)', () {
      // These are sub-agent-specific content that should NOT be in firmware
      expect(content, isNot(contains('epistemic humility')),
          reason: 'Firmware should not contain SOCRATES prompt details');
        expect(content, isNot(contains('INTENTION FIRST')),
          reason: 'Firmware should not contain ADA prompt details');
      expect(content, isNot(contains('Socratic method')),
          reason: 'Firmware should not contain SOCRATES methodology');
      expect(content, isNot(contains('natural selection')),
          reason: 'Firmware should not contain DARWIN methodology');
    });

    test('contains dual FSM structure (outer + inner loop)', () {
      expect(content, contains('Outer Loop'));
      expect(content, contains('Inner Loop'));
    });

    test('mentions _DONE sentinel', () {
      expect(content, contains('_DONE'));
    });

    test('keeps issue readiness inside IDLE TRIAGE', () {
      expect(content, contains('issue readiness stays in IDLE/TRIAGE'));
      expect(content, contains('issue_selected_or_created'));
    });

    test('documents the explicit-start handoff sequence', () {
      expect(content, contains('explicit start intent'));
      expect(content, contains('inquiry-start'));
      expect(content, contains('start_analyze'));
      final issueReadyIndex = content.indexOf('issue_selected_or_created');
      final branchReadyIndex = content.indexOf('feature_branch_selected');
      expect(issueReadyIndex, greaterThanOrEqualTo(0));
      expect(branchReadyIndex, greaterThan(issueReadyIndex));
    });

    test('keeps explicit create/select routing inside IDLE TRIAGE', () {
      expect(
        content,
        contains('explicit create/select intent only changes TRIAGE routing inside IDLE'),
      );
      expect(
        content,
        contains('only explicit start intent triggers inquiry-start plus start_analyze'),
      );
    });

    test('does not treat IDLE handoff markers as ape transitions', () {
      expect(
        content,
        contains('`issue_selected_or_created` is a handoff marker, not an `iq ape transition` event'),
      );
      expect(
        content,
        contains('`feature_branch_selected` is produced by `inquiry-start`, not by `iq ape transition`'),
      );
      expect(
        content,
        contains('do NOT run `iq ape transition`; otherwise run `iq ape transition --event <event>`'),
      );
    });

    test('forbids direct writes to .inquiry/', () {
      expect(content, contains('NEVER'));
      expect(content, contains('.inquiry/'));
    });

    test('requires exact literal output when explicitly requested', () {
      expect(
        content,
        contains('If the user requests an exact literal response'),
      );
      expect(content, contains('output only that literal'));
    });
  });
}
