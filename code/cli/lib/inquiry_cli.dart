/// Public API for the `inquiry` CLI.
///
/// [runInquiry] is the single entry point — called by `bin/main.dart` and by tests.
library;

import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import 'assets.dart';
import 'modules/global/global_builder.dart';
import 'modules/fsm/fsm_builder.dart';
import 'modules/ape/ape_builder.dart';
import 'modules/implementation/implementation_builder.dart';
import 'modules/host/host_builder.dart';
import 'hosts/all_adapters.dart';
import 'hosts/deployer.dart';

/// `--help` / `-h` are NOT normalized here: the SDK routes every help request
/// itself, including the focused `iq <command> --help`, which this could not.
List<String> normalizeInquiryArgs(List<String> args) {
  if (args.length == 1 && (args.first == '--version' || args.first == '-v')) {
    return const ['version'];
  }
  return args;
}

/// Configures the CLI, registers all commands, and dispatches [args].
///
/// Returns a process exit code. [stdout] / [stderr] default to the process
/// streams; tests pass their own sinks to assert on what the user actually sees.
Future<int> runInquiry(
  List<String> args, {
  IOSink? stdout,
  IOSink? stderr,
}) async {
  final cli = ModularCli();

  final assetsRoot = p.dirname(p.dirname(Platform.resolvedExecutable));

  final deployer = HostDeployer(
    assets: Assets(root: assetsRoot),
    adapters: deployAdapters,
    homeDir:
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '',
  );

  final cleaner = HostDeployer(
    assets: Assets(root: assetsRoot),
    adapters: allAdapters,
    homeDir:
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '',
  );

  final assets = Assets(root: assetsRoot);

  cli.module('', (m) => buildGlobalModule(m, cleaner: cleaner, assets: assets));
  cli.module('host', (m) => buildHostModule(m, deployer: deployer, cleaner: cleaner));
  cli.module('fsm', (m) => buildFsmModule(m, assets: assets));
  cli.module('ape', (m) => buildApeModule(m, assets: assets));
  cli.module('implementation', (m) => buildImplementationModule(m, assets: assets));

  return cli.run(normalizeInquiryArgs(args), stdout: stdout, stderr: stderr);
}
