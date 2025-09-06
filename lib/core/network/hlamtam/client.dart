import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:max_killer/core/network/hlamtam/handlers/handler.dart';

import 'constants.dart';
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

    _socket = await SecureSocket.connect(
      serverName,
      port,
      timeout: const Duration(seconds: 5),
    );
    _socket!.listen(_onData, onError: _onError, onDone: _onDone);
  }

  ///
  Future<void> close() async {
    await _socket?.flush();
    await _socket?.close();
    _socket?.destroy();
    _socket = null;
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
    final packet = HlamTamPacket(
      command: command,
      sequence: (_sequence++ & 0xFFFF),
      opcode: opcode,
      data: data,
    );

    final completer = Completer<HlamTamPacket>();
    _responses[packet.sequence] = completer;
    final bytes = packet.toBytes();

    _socket!.add(bytes);
    return completer.future.timeout(const Duration(seconds: 10));
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
          _responses.remove(packet.sequence)?.complete(packet);
          break;

        case HlamTamCommand.request:
          _dispatchToHandler(packet);
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
      return;
    }

    for (final handler in handlers) {
      try {
        await handler.handle(packet, this);
      } catch (e) {}
    }
  }

  void _onError(Object e, [StackTrace? s]) {
    for (final completer in _responses.values) {
      if (!completer.isCompleted) completer.completeError(e, s);
    }
    _responses.clear();
  }

  void _onDone() {
    _onError(StateError('Socket closed'));
  }
}
