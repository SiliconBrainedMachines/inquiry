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

/// Active deploy targets (#280): `iq host get` installs the agent
/// GLOBALLY for these, additively. Copilot/Codex/Gemini are kept only in
/// [allAdapters] for `host clean` migration.
final List<HostAdapter> deployAdapters = [
  OpenCodeAdapter(),
  ClaudeAdapter(),
];
