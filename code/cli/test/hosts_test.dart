import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/hosts/all_adapters.dart';

void main() {
  group('HostAdapter implementations', () {
    for (final adapter in allAdapters) {
      test('${adapter.name} returns non-empty skillsDirectory', () {
        final skillsDir = adapter.skillsDirectory('/home/user');
        expect(skillsDir, isNotEmpty);
      });

      test('${adapter.name} returns non-empty agentDirectory', () {
        final agentDir = adapter.agentDirectory('/home/user');
        expect(agentDir, isNotEmpty);
      });

      test('${adapter.name} returns non-empty baseDirectory', () {
        final baseDir = adapter.baseDirectory('/home/user');
        expect(baseDir, isNotEmpty);
      });

      test('${adapter.name} has a valid name', () {
        expect(adapter.name, isNotEmpty);
      });

      test('${adapter.name} skillsDirectory contains home dir', () {
        final skillsDir = adapter.skillsDirectory('/home/user');
        expect(skillsDir, startsWith('/home/user'));
      });

      test('${adapter.name} agentDirectory contains home dir', () {
        final agentDir = adapter.agentDirectory('/home/user');
        expect(agentDir, startsWith('/home/user'));
      });

      test('${adapter.name} baseDirectory contains home dir', () {
        final baseDir = adapter.baseDirectory('/home/user');
        expect(baseDir, startsWith('/home/user'));
      });
    }
  });

  group('allAdapters registry', () {
    test('returns exactly 5 adapters', () {
      expect(allAdapters, hasLength(5));
    });

    test('each adapter has a unique name', () {
      final names = allAdapters.map((a) => a.name).toSet();
      expect(names, hasLength(5));
    });
  });

  group('deployAdapters registry', () {
    test('returns copilot, opencode, and claude', () {
      expect(deployAdapters, hasLength(3));
      expect(
        deployAdapters.map((a) => a.name),
        containsAll(<String>['copilot', 'opencode', 'claude']),
      );
    });
  });

  group('OpenCode agent directory (regression #247)', () {
    final opencode = deployAdapters.firstWhere((a) => a.name == 'opencode');

    test('agentDirectory is the SINGULAR ~/.config/opencode/agent', () {
      // OpenCode reads global agents from `agent/` (singular). A plural
      // `agents/` is ignored, so the deployed agent is invisible to
      // `opencode agent list` / `--agent inquiry`. Pin the singular form.
      final parts = p.split(opencode.agentDirectory('/home/user'));
      expect(parts.last, 'agent');
      expect(parts.last, isNot('agents'));
      expect(parts[parts.length - 2], 'opencode');
    });
  });

  group('agent deploy is repo-scoped, never global (#272)', () {
    test('opencode does not deploy a global agent', () {
      final opencode = deployAdapters.firstWhere((a) => a.name == 'opencode');
      expect(opencode.deploysAgent, isFalse);
    });

    test('copilot does not deploy a global agent', () {
      final copilot = deployAdapters.firstWhere((a) => a.name == 'copilot');
      expect(copilot.deploysAgent, isFalse);
    });

    test('each host exposes its per-project agent path', () {
      final opencode = deployAdapters.firstWhere((a) => a.name == 'opencode');
      final copilot = deployAdapters.firstWhere((a) => a.name == 'copilot');
      expect(opencode.projectAgentRelPath, p.join('.opencode', 'agent', 'inquiry.md'));
      expect(
        copilot.projectAgentRelPath,
        p.join('.github', 'agents', 'inquiry.agent.md'),
      );
    });
  });
}
