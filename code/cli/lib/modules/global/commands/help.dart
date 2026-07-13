/// `inquiry help` — prints the global CLI help.
///
/// The listing is rendered from the router's own command registry, never from a
/// hand-written string: a maintained-by-hand help drifts the moment a module is
/// added (the `specification` and `issue` modules shipped without ever being
/// listed). Descriptions come from the `description:` given at registration.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

/// Collects [IOSink] writes into a string.
///
/// `printHelp` renders into an [IOSink]; this captures that output so the help
/// can be returned as a value (and asserted in tests) instead of only printed.
class StringIOSink implements IOSink {
  final StringBuffer _buffer = StringBuffer();

  @override
  void write(Object? obj) => _buffer.write(obj);

  @override
  void writeln([Object? obj = '']) => _buffer.writeln(obj);

  @override
  String toString() => _buffer.toString();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

const String inquiryUsageHeader =
    'Usage:\n'
    '  iq                      Display Inquiry status and FSM diagram\n'
    '  iq help | --help | -h   Show this help\n'
    '  iq <command> [options]\n';

/// A listing line whose command is empty — the bare `iq` route registers as the
/// empty string, so the router renders it as an orphan dash. It is already
/// documented in [inquiryUsageHeader].
final RegExp _orphanDescription = RegExp(r'^\s+-\s');

/// Renders the full help for [cli]: the usage header plus every registered
/// command, taken from the router.
String renderInquiryHelp(ModularCli cli) {
  final sink = StringIOSink();
  cli.printHelp(sink);

  final listing = sink
      .toString()
      .split('\n')
      .where((line) => !_orphanDescription.hasMatch(line))
      .join('\n');

  return '$inquiryUsageHeader\n$listing';
}

class HelpInput extends Input {
  HelpInput();

  factory HelpInput.fromCliRequest(CliRequest req) => HelpInput();

  @override
  Map<String, dynamic> toJson() => {};
}

class HelpOutput extends Output {
  final String text;

  HelpOutput({required this.text});

  @override
  Map<String, dynamic> toJson() => {'help': text};

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => text;
}

class HelpCommand implements Command<HelpInput, HelpOutput> {
  @override
  final HelpInput input;

  /// Rendered lazily: `help` is registered before the other modules, and the
  /// listing must include them, so the registry is only read at execute time.
  final String Function() _renderHelp;

  HelpCommand(this.input, {required String Function() renderHelp})
    : _renderHelp = renderHelp;

  @override
  String? validate() => null;

  @override
  Future<HelpOutput> execute() async => HelpOutput(text: _renderHelp());
}
