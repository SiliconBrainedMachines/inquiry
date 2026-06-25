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
    test('active deploy targets are opencode + claude (#280)', () {
      expect(deployAdapters, hasLength(2));
      expect(
        deployAdapters.map((a) => a.name),
        containsAll(<String>['opencode', 'claude']),
      );
      expect(deployAdapters.map((a) => a.name), isNot(contains('copilot')));
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

  group('active hosts deploy the agent globally (#280)', () {
    test('opencode + claude deploy the agent', () {
      for (final name in ['opencode', 'claude']) {
        final a = deployAdapters.firstWhere((a) => a.name == name);
        expect(a.deploysAgent, isTrue, reason: '$name installs a global agent');
      }
    });
  });
}
