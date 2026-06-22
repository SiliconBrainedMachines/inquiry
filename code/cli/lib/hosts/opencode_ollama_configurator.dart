/// Configures OpenCode's Ollama models so the Inquiry firmware fits.
///
/// Run by `iq host get --host opencode`. For each Ollama model in
/// `opencode.jsonc` whose effective `num_ctx` is below [kInquiryMinNumCtx], it
/// bakes a `<model>-16k` variant (`ollama create`, additive — never deletes the
/// original) and rewrites `opencode.jsonc` (with a `.bak` backup) so only
/// adequate models are listed. The result leaves `iq doctor` green.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'ollama_context.dart';

/// Minimal file operations (injectable for tests).
abstract class ConfigFs {
  String? readFile(String path);
  void writeFile(String path, String content);
  void deleteFile(String path);
}

/// Production implementation using dart:io.
class RealConfigFs implements ConfigFs {
  @override
  String? readFile(String path) {
    final f = File(path);
    return f.existsSync() ? f.readAsStringSync() : null;
  }

  @override
  void writeFile(String path, String content) {
    final f = File(path);
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(content);
  }

  @override
  void deleteFile(String path) {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }
}

class OpenCodeOllamaConfigurator {
  final OllamaProcessRunner run;
  final ConfigFs fs;
  final String homeDir;

  OpenCodeOllamaConfigurator({
    required this.run,
    required this.fs,
    required this.homeDir,
  });

  String get _cfgPath =>
      p.join(homeDir, '.config', 'opencode', 'opencode.jsonc');

  /// Ensures every configured Ollama model has num_ctx >= kInquiryMinNumCtx,
  /// baking variants and rewriting the config as needed. Returns human-readable
  /// action lines (empty when there was nothing to do).
  Future<List<String>> configure() async {
    final raw = fs.readFile(_cfgPath);
    if (raw == null) return const [];
    final models = ollamaModelsFromConfig(raw);
    if (models.isEmpty) return const [];

    final actions = <String>[];
    final replacements = <String, String>{};

    for (final model in models) {
      final ctx = await effectiveNumCtx(run, model);
      if (ctx == null) {
        actions.add('skipped $model (could not query Ollama)');
        continue;
      }
      if (ctx >= kInquiryMinNumCtx) continue;

      final variant = '$model-16k';
      final variantCtx = await effectiveNumCtx(run, variant);
      if (variantCtx == null || variantCtx < kInquiryMinNumCtx) {
        final ok = await _bake(model, variant);
        if (!ok) {
          actions.add('failed to create $variant (ollama create)');
          continue;
        }
        actions.add('created Ollama model $variant (num_ctx $kInquiryMinNumCtx)');
      }
      replacements[model] = variant;
    }

    if (replacements.isNotEmpty) {
      fs.writeFile('$_cfgPath.bak', raw);
      fs.writeFile(_cfgPath, _rewriteConfig(raw, replacements));
      actions.add(
        'updated opencode.jsonc — Ollama models now: '
        '${replacements.values.join(', ')} (backup: opencode.jsonc.bak)',
      );
    }
    return actions;
  }

  Future<bool> _bake(String base, String variant) async {
    final modelfile = p.join(homeDir, '.config', 'opencode', '.inquiry.Modelfile');
    fs.writeFile(modelfile, 'FROM $base\nPARAMETER num_ctx $kInquiryMinNumCtx\n');
    try {
      final res = await run('ollama', ['create', variant, '-f', modelfile]);
      return res.exitCode == 0;
    } catch (_) {
      return false;
    } finally {
      fs.deleteFile(modelfile);
    }
  }

  /// Rewrites opencode.jsonc, replacing each inadequate model key with its
  /// adequate variant (preserving the variant's metadata if already present).
  String _rewriteConfig(String raw, Map<String, String> replacements) {
    final json = jsonDecode(stripJsonComments(raw)) as Map<String, dynamic>;
    final provider = json['provider'] as Map;
    final ollama = provider['ollama'] as Map;
    final models = Map<String, dynamic>.from(ollama['models'] as Map);
    replacements.forEach((bad, variant) {
      final meta = models.remove(bad);
      models.putIfAbsent(
        variant,
        () => meta ?? <String, dynamic>{'name': variant},
      );
    });
    ollama['models'] = models;
    return '${const JsonEncoder.withIndent('  ').convert(json)}\n';
  }
}
