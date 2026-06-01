import 'dart:io';

import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/cycle_fixture.dart';

void main() {
  late Directory tmpDir;
  late String stateFile;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('inquiry_state_test_');
    stateFile = p.join(tmpDir.path, kStateFileName);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('InquiryState.loadFrom', () {
    test('returns IDLE when state file is missing', () {
      final state = InquiryState.loadFrom(stateFile);
      expect(state.state, equals('IDLE'));
      expect(state.issue, isNull);
      expect(state.apeName, isNull);
      expect(state.apeState, isNull);
    });

    test('reads basic state and issue', () {
      File(
        stateFile,
      ).writeAsStringSync('state: ANALYZE\nissue: "145"\nape: null\n');

      final state = InquiryState.loadFrom(stateFile);
      expect(state.state, equals('ANALYZE'));
      expect(state.issue, equals('145'));
      expect(state.apeName, isNull);
    });

    test('reads state with ape field', () {
      File(stateFile).writeAsStringSync(
        'state: ANALYZE\n'
        'issue: "145"\n'
        'prompt_fragment_id: analyze_continue\n'
        'ape:\n'
        '  name: socrates\n'
        '  state: clarification\n',
      );

      final state = InquiryState.loadFrom(stateFile);
      expect(state.state, equals('ANALYZE'));
      expect(state.issue, equals('145'));
      expect(state.promptFragmentId, equals('analyze_continue'));
      expect(state.apeName, equals('socrates'));
      expect(state.apeState, equals('clarification'));
    });

    test('reads integer issue as string', () {
      File(stateFile).writeAsStringSync('state: PLAN\nissue: 99\nape: null\n');

      final state = InquiryState.loadFrom(stateFile);
      expect(state.issue, equals('99'));
    });

    test('handles null issue', () {
      File(
        stateFile,
      ).writeAsStringSync('state: IDLE\nissue: null\nape: null\n');

      final state = InquiryState.loadFrom(stateFile);
      expect(state.issue, isNull);
    });

    test('reads new schema fields: version, status, timestamps', () {
      File(stateFile).writeAsStringSync(
        'version: 1\n'
        'state: PLAN\n'
        'issue: "42"\n'
        'status: active\n'
        'created_at: "2026-01-01T00:00:00.000Z"\n'
        'updated_at: "2026-01-02T00:00:00.000Z"\n',
      );

      final state = InquiryState.loadFrom(stateFile);
      expect(state.version, equals(1));
      expect(state.status, equals('active'));
      expect(state.createdAt, equals('2026-01-01T00:00:00.000Z'));
      expect(state.updatedAt, equals('2026-01-02T00:00:00.000Z'));
    });

    test('backward compat: reads old format without ape field', () {
      File(stateFile).writeAsStringSync('state: PLAN\nissue: "42"\n');

      final state = InquiryState.loadFrom(stateFile);
      expect(state.state, equals('PLAN'));
      expect(state.issue, equals('42'));
      expect(state.promptFragmentId, isNull);
      expect(state.apeName, isNull);
      expect(state.apeState, isNull);
      expect(state.version, equals(1));
    });
  });

  group('InquiryState.saveTo', () {
    test('writes full format with ape field and schema metadata', () {
      const state = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        promptFragmentId: 'analyze_continue',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      state.saveTo(stateFile);

      final content = File(stateFile).readAsStringSync();
      expect(content, contains('version: 1'));
      expect(content, contains('state: ANALYZE'));
      expect(content, contains('issue: "145"'));
      expect(content, contains('prompt_fragment_id: analyze_continue'));
      expect(content, contains('status: active'));
      expect(content, contains('ape:'));
      expect(content, contains('  name: socrates'));
      expect(content, contains('  state: clarification'));
      expect(content, contains('created_at:'));
      expect(content, contains('updated_at:'));
    });

    test('writes ape: null when no APE', () {
      const state = InquiryState(state: 'IDLE');
      state.saveTo(stateFile);

      final content = File(stateFile).readAsStringSync();
      expect(content, contains('state: IDLE'));
      expect(content, contains('issue: null'));
      expect(content, contains('ape: null'));
    });

    test('creates parent directory when missing', () {
      final nested = p.join(tmpDir.path, 'cleanrooms', 'x', kStateFileName);

      const state = InquiryState(state: 'IDLE');
      state.saveTo(nested);

      final file = File(nested);
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('state: IDLE'));
    });

    test('preserves created_at across saves', () {
      const original = InquiryState(
        state: 'PLAN',
        issue: '7',
        createdAt: '2026-01-01T00:00:00.000Z',
      );
      original.saveTo(stateFile);

      final content = File(stateFile).readAsStringSync();
      expect(content, contains('created_at: "2026-01-01T00:00:00.000Z"'));
    });

    test('roundtrips correctly', () {
      const original = InquiryState(
        state: 'EXECUTE',
        issue: '200',
        promptFragmentId: 'plan_to_execute',
        apeName: 'ada',
        apeState: 'frame_intent',
      );
      original.saveTo(stateFile);

      final loaded = InquiryState.loadFrom(stateFile);
      expect(loaded.state, equals('EXECUTE'));
      expect(loaded.issue, equals('200'));
      expect(loaded.promptFragmentId, equals('plan_to_execute'));
      expect(loaded.apeName, equals('ada'));
      expect(loaded.apeState, equals('frame_intent'));
    });
  });

  group('InquiryState cycle-local resolution', () {
    test('load returns IDLE outside a git repository', () {
      final state = InquiryState.load(tmpDir.path);
      expect(state.state, equals('IDLE'));
    });

    test('stateFileFor resolves cleanrooms/<branch>/.iq.state.yaml', () {
      final expected = setupCycle(tmpDir.path, branch: '209-foo');
      final resolved = InquiryState.stateFileFor(tmpDir.path);
      expect(resolved, isNotNull);

      final expectedDir = Directory(
        p.dirname(expected),
      ).resolveSymbolicLinksSync();
      final resolvedDir = Directory(
        p.dirname(resolved!),
      ).resolveSymbolicLinksSync();

      expect(resolvedDir, equals(expectedDir));
      expect(p.basename(resolved), equals(kStateFileName));
    });

    test('save then load roundtrips via cycle-local path', () {
      final expected = setupCycle(tmpDir.path, branch: '209-foo');
      const state = InquiryState(state: 'ANALYZE', issue: '209');
      state.save(tmpDir.path);

      expect(File(expected).existsSync(), isTrue);
      final loaded = InquiryState.load(tmpDir.path);
      expect(loaded.state, equals('ANALYZE'));
      expect(loaded.issue, equals('209'));
    });

    test('load returns IDLE when cycle status is completed', () {
      setupCycle(tmpDir.path, branch: '209-foo');
      const state = InquiryState(state: 'EVOLUTION', status: 'completed');
      state.save(tmpDir.path);

      final loaded = InquiryState.load(tmpDir.path);
      expect(loaded.state, equals('IDLE'));
    });

    test('load returns IDLE when cycle status is blocked', () {
      setupCycle(tmpDir.path, branch: '209-foo');
      const state = InquiryState(state: 'ANALYZE', status: 'blocked');
      state.save(tmpDir.path);

      final loaded = InquiryState.load(tmpDir.path);
      expect(loaded.state, equals('IDLE'));
    });

    test('save throws when no cycle resolves (IDLE is derived)', () {
      const state = InquiryState(state: 'ANALYZE');
      expect(() => state.save(tmpDir.path), throwsA(isA<StateError>()));
    });
  });

  group('InquiryState.copyWith', () {
    test('copies with new state', () {
      const original = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        promptFragmentId: 'analyze_continue',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      final copy = original.copyWith(state: 'PLAN');

      expect(copy.state, equals('PLAN'));
      expect(copy.issue, equals('145'));
      expect(copy.promptFragmentId, equals('analyze_continue'));
      expect(copy.apeName, equals('socrates'));
      expect(copy.apeState, equals('clarification'));
    });

    test('copies with new apeState', () {
      const original = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        promptFragmentId: 'analyze_continue',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      final copy = original.copyWith(apeState: 'assumptions');

      expect(copy.apeState, equals('assumptions'));
      expect(copy.promptFragmentId, equals('analyze_continue'));
      expect(copy.apeName, equals('socrates'));
    });

    test('copies with new status', () {
      const original = InquiryState(state: 'EVOLUTION', status: 'active');
      final copy = original.copyWith(status: 'completed');

      expect(copy.status, equals('completed'));
      expect(copy.state, equals('EVOLUTION'));
    });

    test('clearApe removes ape fields', () {
      const original = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        promptFragmentId: 'analyze_continue',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      final copy = original.copyWith(clearApe: true);

      expect(copy.state, equals('ANALYZE'));
      expect(copy.issue, equals('145'));
      expect(copy.promptFragmentId, equals('analyze_continue'));
      expect(copy.apeName, isNull);
      expect(copy.apeState, isNull);
    });
  });
}
