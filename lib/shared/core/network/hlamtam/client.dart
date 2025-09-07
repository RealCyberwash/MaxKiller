import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:max_killer/shared/core/log.dart';
import 'package:max_killer/shared/core/network/hlamtam/handlers/handler.dart';

import 'constants.dart';
import 'exceptions/api.dart';
import 'exceptions/base.dart';
import 'packet.dart';

///
@singleton
class HlamTamClient {
  Socket? _socket;
  int _sequence = 0;
  final _responses = <int, Completer<HlamTamPacket>>{};
  final _buffer = BytesBuilder();
  final _handlers = <HlamTamOpcode, List<HlamTamHandler>>{};

  ///
  Future<void> connect(HlamTamDomain domain, int port) async {
    final serverName = domain.host;

    log.i(() => 'Connecting to $serverName:$port ...');
    _socket = await SecureSocket.connect(
      serverName,
      port,
      timeout: const Duration(seconds: 5),
    );
    log.i(() => 'Connected to $serverName:$port');
    _socket!.listen(_onData, onError: _onError, onDone: _onDone);
  }

  ///
  Future<void> close() async {
    log.i(() => 'Closing socket ...');
    await _socket?.flush();
    await _socket?.close();
    _socket?.destroy();
    _socket = null;
    log.i(() => 'Socket closed');
  }

  ///
  void on(HlamTamHandler handler) {
    _handlers.putIfAbsent(handler.opcode, () => []).add(handler);
  }

  ///
  Future<HlamTamPacket> send(
    HlamTamCommand command,
    HlamTamOpcode opcode,
    Map<String, dynamic> data,
  ) async {
    if (_socket == null) {
      throw StateError('Socket is not connected');
    }

    final packet = HlamTamPacket(
      command: command,
      sequence: (_sequence++ & 0xFFFF),
      opcode: opcode,
      data: data,
    );

    final completer = Completer<HlamTamPacket>();
    _responses[packet.sequence] = completer;

    final bytes = packet.toBytes();
    log.t(() => 'TX $packet size=${bytes.length}');
    _socket!.add(bytes);

    final timer = Timer(const Duration(seconds: 10), () {
      final completer = _responses.remove(packet.sequence);
      if (completer != null && !completer.isCompleted) {
        completer.completeError(TimeoutException('Request timed out'));
      }
    });

    return completer.future.whenComplete(() => timer.cancel());
  }

  ///
  Future<void> reply(HlamTamPacket packet, Map<String, dynamic> data) async {
    final response = HlamTamPacket(
      command: HlamTamCommand.response,
      sequence: packet.sequence,
      opcode: packet.opcode,
      data: data,
    );

    _socket?.add(response.toBytes());
  }

  void _onData(List<int> chunk) {
    _buffer.add(chunk);

    while (true) {
      final bytes = _buffer.toBytes();

      if (bytes.length < HlamTamTcp.headerSize) break;

      HlamTamTryParseResult? tryResult;
      try {
        tryResult = HlamTamPacket.tryParse(bytes);
      } catch (e, s) {
        _onError(HlamTamException('Parse error: $e'), s);
        return;
      }

      if (tryResult == null) break;

      final packet = tryResult.packet;
      final consumed = tryResult.consumed;

      switch (packet.command) {
        case HlamTamCommand.response:
          log.t(() => 'RX response $packet consumed=$consumed');
          _responses.remove(packet.sequence)?.complete(packet);
          break;

        case HlamTamCommand.request:
          log.t(() => 'RX request $packet consumed=$consumed');
          _dispatchToHandler(packet);
          break;

        case HlamTamCommand.error:
          log.t(() => 'RX error $packet consumed=$consumed');
          final error = HlamTamApiError.fromPacket(packet);
          final completer = _responses.remove(packet.sequence);
          completer?.completeError(error);
          break;
      }

      final rest = bytes.sublist(consumed);
      _buffer.clear();
      if (rest.isNotEmpty) _buffer.add(rest);
    }
  }

  Future<void> _dispatchToHandler(HlamTamPacket packet) async {
    final handlers = _handlers[packet.opcode];
    if (handlers == null || handlers.isEmpty) {
      log.w(() => 'No handlers for opcode=${packet.opcode}');
      return;
    }

    for (final handler in handlers) {
      try {
        await handler.handle(packet, this);
      } catch (e, s) {
        log.e(
          () => 'Handler error for opcode=${packet.opcode}: $e',
          error: e,
          stackTrace: s,
        );
      }
    }
  }

  void _onError(Object e, [StackTrace? s]) {
    final pending = _responses.length;
    log.e(
      () => 'Socket error; failing $pending pending request(s): $e',
      error: e,
      stackTrace: s,
    );
    for (final completer in _responses.values) {
      if (!completer.isCompleted) completer.completeError(e, s);
    }
    _responses.clear();
  }

  void _onDone() {
    log.w(() => 'Socket connection closed by remote');
    _onError(StateError('Socket closed'));
  }
}
