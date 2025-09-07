import 'package:max_killer/shared/core/log.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'api.dart';
import 'client.dart';
import 'constants.dart';
import 'exceptions/protocol.dart';
import 'operations/operation.dart';
import 'operations/selector.dart';

///
class HlamTamApiImpl implements HlamTamApi {
  ///
  HlamTamApiImpl({
    required this.client,
    required this.version,
    required HlamTamOperationSelector operationSelector,
  }) : _operationSelector = operationSelector;

  ///
  final HlamTamClient client;

  ///
  final int version;

  ///
  final HlamTamOperationSelector _operationSelector;

  ///
  @override
  Future<R> send<R extends HlamTamResponse>(
    HlamTamOperation<R> operation,
  ) async {
    if (!operation.supports(version)) {
      log.w(
        () =>
            'Operation ${operation.runtimeType} is not supported by protocol v$version',
      );
      throw StateError(
        'Operation ${operation.runtimeType} does not support the protocol v$version',
      );
    }

    log.d(
      () =>
          'Sending ${operation.runtimeType} v$version opcode=${operation.opcode}',
    );
    final stopwatch = Stopwatch()..start();

    final packet = await client.send(
      HlamTamCommand.request,
      operation.opcode,
      operation.toPayload(),
    );
    final data = packet.data;

    if (data['error'] != null) {
      log.w(
        () =>
            'Protocol error for ${operation.runtimeType}: '
            'opcode=${operation.opcode} seq=${packet.sequence} '
            'code=${data['error']} message=${data['message']}',
      );
      throw ProtocolError(
        code: data['error'] as String,
        message: (data['message'] as String?) ?? 'Unknown error',
        packet: packet,
      );
    }

    try {
      final result = operation.fromPayload(data);

      stopwatch.stop();

      log.i(
        () =>
            'OK ${operation.runtimeType} v$version opcode=${operation.opcode} '
            'seq=${packet.sequence} in=${stopwatch.elapsedMilliseconds}ms',
      );

      return result;
    } on Object catch (e) {
      stopwatch.stop();

      log.e(
        () =>
            'Response parse failed for ${operation.runtimeType} v$version opcode=${operation.opcode} '
            'seq=${packet.sequence} in=${stopwatch.elapsedMilliseconds}ms',
        error: e,
      );
      throw StateError(
        'Parse failed for ${operation.runtimeType} v$version, opcode ${operation.opcode}: $e',
      );
    }
  }

  @override
  Future<R> sendVersioned<R extends HlamTamResponse>(
    int version,
    List<HlamTamOperationFactory<R>> candidates,
  ) {
    final operation = _operationSelector.pick(version, candidates);
    return send(operation);
  }
}
