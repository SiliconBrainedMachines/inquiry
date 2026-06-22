import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/hosts/ollama_context.dart';
import 'package:inquiry_cli/hosts/opencode_ollama_configurator.dart';

class FakeConfigFs implements ConfigFs {
  final Map<String, String> files = {};
  @override
  String? readFile(String path) => files[path];
  @override
  void writeFile(String path, String content) => files[path] = content;
  @override
  void deleteFile(String path) => files.remove(path);
}

/// Stateful fake `ollama`: `show` reflects the [ctx] map (missing model → exit
/// 1); `create <variant>` registers it at 16384. When [available] is false,
/// every call fails (simulating Ollama not installed).
OllamaProcessRunner fakeOllama(Map<String, int> ctx, {bool available = true}) {
  return (String exe, List<String> args, {String? workingDirectory}) async {
    if (!available) return ProcessResult(0, 1, '', 'ollama: not found');
    if (exe == 'ollama' && args.isNotEmpty && args.first == 'show') {
      final model = args[1];
      if (!ctx.containsKey(model)) {
        return ProcessResult(0, 1, '', 'model not found');
      }
      return ProcessResult(0, 0, 'FROM base\nPARAMETER num_ctx ${ctx[model]}\n', '');
    }
    if (exe == 'ollama' && args.isNotEmpty && args.first == 'create') {
      ctx[args[1]] = 16384; // variant now exists
      return ProcessResult(0, 0, 'success', '');
    }
    return ProcessResult(0, 0, '', '');
  };
}

const home = '/home/test';
// Must match the configurator's own p.join(homeDir, ...) (separators differ by OS).
final cfgPath = p.join(home, '.config', 'opencode', 'opencode.jsonc');

String cfg(List<String> models) {
  final entries = models.map((m) => '"$m": {}').join(', ');
  return '{ "provider": { "ollama": { "models": { $entries } } } }';
}

void main() {
  group('OpenCodeOllamaConfigurator', () {
    test('replaces a 4096 model with its existing 16k variant (no re-bake)', () async {
      final fs = FakeConfigFs()
        ..files[cfgPath] = cfg(['qwen3-coder:30b', 'qwen3-coder:30b-16k']);
      final ctx = {'qwen3-coder:30b': 4096, 'qwen3-coder:30b-16k': 16384};
      final cfgr = OpenCodeOllamaConfigurator(
        run: fakeOllama(ctx),
        fs: fs,
        homeDir: home,
      );

      final actions = await cfgr.configure();

      final models = ollamaModelsFromConfig(fs.files[cfgPath]!);
      expect(models, equals(['qwen3-coder:30b-16k']),
          reason: 'inadequate model dropped, adequate variant kept');
      expect(fs.files['$cfgPath.bak'], isNotNull, reason: 'original backed up');
      expect(actions.join('\n'), contains('updated opencode.jsonc'));
      expect(actions.join('\n'), isNot(contains('created')),
          reason: 'variant already adequate — must not re-bake');
    });

    test('bakes a 16k variant when none exists, then lists it', () async {
      final fs = FakeConfigFs()..files[cfgPath] = cfg(['gemma4:12b']);
      final ctx = {'gemma4:12b': 4096}; // no -16k variant yet
      final cfgr = OpenCodeOllamaConfigurator(
        run: fakeOllama(ctx),
        fs: fs,
        homeDir: home,
      );

      final actions = await cfgr.configure();

      expect(ctx.containsKey('gemma4:12b-16k'), isTrue,
          reason: 'ollama create was invoked for the variant');
      expect(ctx['gemma4:12b-16k'], 16384);
      expect(ollamaModelsFromConfig(fs.files[cfgPath]!),
          equals(['gemma4:12b-16k']));
      expect(actions.join('\n'), contains('created Ollama model gemma4:12b-16k'));
    });

    test('does nothing when all models already have num_ctx >= 16384', () async {
      final original = cfg(['qwen3-coder:30b-16k']);
      final fs = FakeConfigFs()..files[cfgPath] = original;
      final cfgr = OpenCodeOllamaConfigurator(
        run: fakeOllama({'qwen3-coder:30b-16k': 32768}),
        fs: fs,
        homeDir: home,
      );

      final actions = await cfgr.configure();

      expect(actions, isEmpty);
      expect(fs.files[cfgPath], original, reason: 'config untouched');
      expect(fs.files.containsKey('$cfgPath.bak'), isFalse);
    });

    test('skips (no mutation) when Ollama cannot be queried', () async {
      final original = cfg(['qwen3-coder:30b']);
      final fs = FakeConfigFs()..files[cfgPath] = original;
      final cfgr = OpenCodeOllamaConfigurator(
        run: fakeOllama({'qwen3-coder:30b': 4096}, available: false),
        fs: fs,
        homeDir: home,
      );

      final actions = await cfgr.configure();

      expect(actions.join('\n'), contains('could not query Ollama'));
      expect(fs.files[cfgPath], original, reason: 'config untouched');
      expect(fs.files.containsKey('$cfgPath.bak'), isFalse);
    });

    test('no-op when there is no opencode.jsonc', () async {
      final fs = FakeConfigFs();
      final cfgr = OpenCodeOllamaConfigurator(
        run: fakeOllama({}),
        fs: fs,
        homeDir: home,
      );
      expect(await cfgr.configure(), isEmpty);
    });
  });
}
