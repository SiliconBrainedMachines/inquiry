library;

import '../../assets.dart';

class InstructionPromptLoader {
  final Assets assets;

  const InstructionPromptLoader({required this.assets});

  String load(String name) {
    final content = assets.loadString('instructions/$name.md');
    return _extractPromptSummary(content, name);
  }

  String loadMany(Iterable<String> names) {
    return names.map(load).join('\n\n');
  }

  String _extractPromptSummary(String content, String name) {
    final lines = content.replaceAll('\r\n', '\n').split('\n');
    final startIndex = lines.indexWhere(
      (line) => line.trim().toLowerCase() == '## prompt summary',
    );

    if (startIndex == -1) {
      throw StateError(
        'Instruction $name is missing a "## Prompt Summary" section.',
      );
    }

    final extracted = <String>[];
    for (var index = startIndex + 1; index < lines.length; index++) {
      var line = lines[index].trim();
      if (line.startsWith('#')) {
        break;
      }
      if (line.isEmpty) {
        continue;
      }

      line = line.replaceFirst(RegExp(r'^[-*]\s+'), '');
      line = line.replaceFirst(RegExp(r'^\d+\.\s+'), '');
      line = line.replaceAll('`', '');
      if (line.isNotEmpty) {
        extracted.add(line);
      }
    }

    if (extracted.isEmpty) {
      throw StateError(
        'Instruction $name has an empty "## Prompt Summary" section.',
      );
    }

    return extracted.join('\n');
  }
}