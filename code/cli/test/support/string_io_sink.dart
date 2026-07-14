import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Collects [IOSink] writes into a string, so what the CLI prints can be
/// asserted instead of only its exit code.
class StringIOSink implements IOSink {
  final StringBuffer _buffer = StringBuffer();

  @override
  void write(Object? obj) => _buffer.write(obj);

  @override
  void writeln([Object? obj = '']) => _buffer.writeln(obj);

  @override
  Encoding encoding = utf8;

  @override
  Future<void> get done => Future.value();

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}

  @override
  String toString() => _buffer.toString();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
