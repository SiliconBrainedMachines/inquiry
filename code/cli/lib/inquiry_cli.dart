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
import 'modules/host/host_builder.dart';
import 'hosts/all_adapters.dart';
import 'hosts/deployer.dart';
import 'hosts/opencode_ollama_configurator.dart';

List<String> normalizeInquiryArgs(List<String> args) {
  if (args.length == 1 && (args.first == '--help' || args.first == '-h')) {
    return const ['help'];
  }
  if (args.length == 1 && (args.first == '--version' || args.first == '-v')) {
    return const ['version'];
  }
  return args;
}

/// Configures the CLI, registers all commands, and dispatches [args].
///
/// Returns a process exit code.
Future<int> runInquiry(List<String> args) async {
  final cli = ModularCli();

  final assetsRoot = p.dirname(p.dirname(Platform.resolvedExecutable));
  final homeDir =
      Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      '';

  // `cleaner` spans ALL adapters so `iq host clean` removes stale global
  // deploys from any older version (migration).
  final cleaner = HostDeployer(
    assets: Assets(root: assetsRoot),
    adapters: allAdapters,
    homeDir: homeDir,
  );

  final assets = Assets(root: assetsRoot);

  // OpenCode/Ollama num_ctx auto-config, used by `iq init --host opencode`.
  final configurator = OpenCodeOllamaConfigurator(
    run: Process.run,
    fs: RealConfigFs(),
    homeDir: homeDir,
  );

  cli.module(
    '',
    (m) => buildGlobalModule(
      m,
      cleaner: cleaner,
      assets: assets,
      configurator: configurator,
    ),
  );
  cli.module('host', (m) => buildHostModule(m, cleaner: cleaner));
  cli.module('fsm', (m) => buildFsmModule(m, assets: assets));
  cli.module('ape', (m) => buildApeModule(m, assets: assets));

  return cli.run(normalizeInquiryArgs(args));
}
