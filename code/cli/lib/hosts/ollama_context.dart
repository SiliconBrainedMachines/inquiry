/// Shared OpenCode + Ollama context helpers.
///
/// Used by both `iq doctor` (verify) and `iq host get` (configure) so the
/// num_ctx / config-parsing logic lives in exactly one place.
library;

import 'dart:convert';
import 'dart:io';

/// Function type for running external processes (injectable for tests).
typedef OllamaProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Minimum Ollama `num_ctx` for the Inquiry firmware + OpenCode tool schemas to
/// fit (the assembled prompt measures ~7.3–7.9k tokens; a full cycle approaches
/// 16k). 32768+ is recommended for long cycles.
const int kInquiryMinNumCtx = 16384;

/// Ollama's default `num_ctx` when a model's Modelfile does not set it.
const int kOllamaDefaultNumCtx = 4096;

/// Strips `//` and `/* */` comments from JSONC, respecting string literals
/// (so the `//` inside a `"$schema": "https://…"` URL is preserved).
String stripJsonComments(String s) {
  final buf = StringBuffer();
  var i = 0;
  var inStr = false;
  var esc = false;
  while (i < s.length) {
    final c = s[i];
    if (inStr) {
      buf.write(c);
      if (esc) {
        esc = false;
      } else if (c == '\\') {
        esc = true;
      } else if (c == '"') {
        inStr = false;
      }
      i++;
      continue;
    }
    if (c == '"') {
      inStr = true;
      buf.write(c);
      i++;
      continue;
    }
    if (c == '/' && i + 1 < s.length && s[i + 1] == '/') {
      i += 2;
      while (i < s.length && s[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && i + 1 < s.length && s[i + 1] == '*') {
      i += 2;
      while (i + 1 < s.length && !(s[i] == '*' && s[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }
    buf.write(c);
    i++;
  }
  return buf.toString();
}

/// Extracts the Ollama provider model names from opencode.jsonc (JSONC text).
List<String> ollamaModelsFromConfig(String jsonc) {
  try {
    final json = jsonDecode(stripJsonComments(jsonc)) as Map<String, dynamic>;
    final provider = json['provider'];
    if (provider is! Map) return [];
    final ollama = provider['ollama'];
    if (ollama is! Map) return [];
    final models = ollama['models'];
    if (models is! Map) return [];
    return models.keys.map((k) => k.toString()).toList();
  } catch (_) {
    return [];
  }
}

/// Effective `num_ctx` for an Ollama model: the Modelfile `PARAMETER num_ctx`
/// if set, else Ollama's 4096 default. Null if Ollama can't be queried
/// (not installed / command failed).
Future<int?> effectiveNumCtx(OllamaProcessRunner run, String model) async {
  try {
    final res = await run('ollama', ['show', model, '--modelfile']);
    if (res.exitCode != 0) return null;
    final out = res.stdout?.toString() ?? '';
    final m = RegExp(r'num_ctx\s+(\d+)', caseSensitive: false).firstMatch(out);
    if (m != null) return int.tryParse(m.group(1)!) ?? kOllamaDefaultNumCtx;
    return kOllamaDefaultNumCtx;
  } catch (_) {
    return null;
  }
}
