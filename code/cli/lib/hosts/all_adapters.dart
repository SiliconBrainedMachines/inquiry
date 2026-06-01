import 'claude_adapter.dart';
import 'codex_adapter.dart';
import 'copilot_adapter.dart';
import 'gemini_adapter.dart';
import 'opencode_adapter.dart';
import 'host_adapter.dart';

/// All known adapters — used by [HostDeployer.clean] for backward
/// compatibility (removes orphaned files from previous multi-host deploys).
final List<HostAdapter> allAdapters = [
  CopilotAdapter(),
  ClaudeAdapter(),
  CodexAdapter(),
  OpenCodeAdapter(),
  GeminiAdapter(),
];

/// Adapters that receive deploys in the current version.
/// For v0.0.x only Copilot is active (D20).
final List<HostAdapter> deployAdapters = [CopilotAdapter()];
