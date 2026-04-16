import 'claude_adapter.dart';
import 'codex_adapter.dart';
import 'copilot_adapter.dart';
import 'crush_adapter.dart';
import 'gemini_adapter.dart';
import 'target_adapter.dart';

final List<TargetAdapter> allAdapters = [
  CopilotAdapter(),
  ClaudeAdapter(),
  CodexAdapter(),
  CrushAdapter(),
  GeminiAdapter(),
];
