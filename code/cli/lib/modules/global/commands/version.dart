/// `inquiry version` — prints the current CLI version.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../src/version.dart';
// Re-export version constant for backward compatibility.
export '../../../src/version.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class VersionInput extends Input {
  VersionInput();

  factory VersionInput.fromCliRequest(CliRequest req) => VersionInput();

    /// Declares an EMPTY contract: this command accepts no option at all, so any
  /// option passed to it is refused. Omitting `params` would mean "declares
  /// nothing" — which is how `iq init --host claude` used to run, doing nothing
  /// the flag implied.
  static const List<CliParam> params = [];

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class VersionOutput extends Output {
  final String version;

  VersionOutput({required this.version});

  @override
  Map<String, dynamic> toJson() => {'version': version};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class VersionCommand implements Command<VersionInput, VersionOutput> {
  @override
  final VersionInput input;

  VersionCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<VersionOutput> execute() async {
    return VersionOutput(version: inquiryVersion);
  }
}
