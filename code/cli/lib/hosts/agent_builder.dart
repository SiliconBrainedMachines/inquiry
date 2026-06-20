import '../assets.dart';
import 'host_adapter.dart';

/// Assembles a host-specific inquiry agent firmware `.md` from a **single**
/// shared body (`agents/inquiry.body.md`) and the host's frontmatter YAML
/// (`adapter.agentFrontmatterAsset`), applying the host's body substitutions.
///
/// This is the one source of truth for the firmware body. The only legitimate
/// per-host differences are the frontmatter schema (e.g. Copilot `name`/`tools`
/// vs OpenCode `mode: primary`) and declared substitutions (e.g. the install
/// hint), so the body can never drift between hosts.
class AgentBuilder {
  final Assets assets;

  AgentBuilder(this.assets);

  /// Builds the full agent markdown (frontmatter + body) for [adapter].
  String build(HostAdapter adapter) {
    final frontmatter = assets.loadString(adapter.agentFrontmatterAsset).trim();
    var body = assets.loadString('agents/inquiry.body.md');
    adapter.agentSubstitutions.forEach((key, value) {
      body = body.replaceAll('{{$key}}', value);
    });
    return '---\n$frontmatter\n---\n\n$body';
  }
}
