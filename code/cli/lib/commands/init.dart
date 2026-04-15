/// `ape init` — creates the `.ape/` directory in the working directory.
///
/// If `.ape/` already exists, reports it without failing.
/// v0.0.1: no flags, no prerequisites, no content inside `.ape/`.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

/// Carries the working directory where `.ape/` will be created.
///
/// Defaults to [Directory.current] when constructed from a [CliRequest],
/// but accepts an explicit path for testing.
class InitInput extends Input {
  final String workingDirectory;

  InitInput({required this.workingDirectory});

  factory InitInput.fromCliRequest(CliRequest req) =>
      InitInput(workingDirectory: Directory.current.path);

  @override
  Map<String, dynamic> toJson() => {'workingDirectory': workingDirectory};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class InitOutput extends Output {
  final String message;
  final bool isCreated;

  InitOutput({required this.message, required this.isCreated});

  @override
  Map<String, dynamic> toJson() => {
        'message': message,
        'created': isCreated,
      };

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

/// Creates `.ape/` in [InitInput.workingDirectory].
///
/// Idempotent: if the directory already exists, returns an informational
/// message instead of failing.
class InitCommand implements Command<InitInput, InitOutput> {
  @override
  final InitInput input;

  InitCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<InitOutput> execute() async {
    final apeDir = Directory('${input.workingDirectory}/.ape');

    if (apeDir.existsSync()) {
      return InitOutput(
        message: '.ape/ already exists in ${input.workingDirectory}',
        isCreated: false,
      );
    }

    apeDir.createSync();
    return InitOutput(
      message: '.ape/ created in ${input.workingDirectory}',
      isCreated: true,
    );
  }
}
