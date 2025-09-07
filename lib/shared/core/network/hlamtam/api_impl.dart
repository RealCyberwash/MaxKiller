import 'package:max_killer/shared/core/log.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';

import 'api.dart';
import 'client.dart';
import 'constants.dart';
import 'endpoints/endpoint.dart';
import 'endpoints/selector.dart';
import 'exceptions/protocol.dart';

///
class HlamTamApiImpl implements HlamTamApi {
  ///
  HlamTamApiImpl({
    required this.client,
    required this.version,
    required EndpointSelector endpointSelector,
  }) : _endpointSelector = endpointSelector;

  ///
  final HlamTamClient client;

  ///
  final int version;

  ///
  final EndpointSelector _endpointSelector;

  ///
  @override
  Future<R> send<R extends HlamTamResponse>(Endpoint<R> endpoint) async {
    if (!endpoint.supports(version)) {
      log.w(
        () =>
            'Endpoint ${endpoint.runtimeType} is not supported by protocol v$version',
      );
      throw StateError(
        'Endpoint ${endpoint.runtimeType} does not support the protocol v$version',
      );
    }

    log.d(
      () =>
          'Sending ${endpoint.runtimeType} v$version opcode=${endpoint.opcode}',
    );
    final stopwatch = Stopwatch()..start();

    final packet = await client.send(
      HlamTamCommand.request,
      endpoint.opcode,
      endpoint.toPayload(),
    );
    final data = packet.data;

    if (data['error'] != null) {
      log.w(
        () =>
            'Protocol error for ${endpoint.runtimeType}: '
            'opcode=${endpoint.opcode} seq=${packet.sequence} '
            'code=${data['error']} message=${data['message']}',
      );
      throw ProtocolError(
        code: data['error'] as String,
        message: (data['message'] as String?) ?? 'Unknown error',
        packet: packet,
      );
    }

    try {
      final result = endpoint.fromPayload(data);

      stopwatch.stop();

      log.i(
        () =>
            'OK ${endpoint.runtimeType} v$version opcode=${endpoint.opcode} '
            'seq=${packet.sequence} in=${stopwatch.elapsedMilliseconds}ms',
      );

      return result;
    } on Object catch (e) {
      stopwatch.stop();

      log.e(
        () =>
            'Response parse failed for ${endpoint.runtimeType} v$version opcode=${endpoint.opcode} '
            'seq=${packet.sequence} in=${stopwatch.elapsedMilliseconds}ms',
        error: e,
      );
      throw StateError(
        'Parse failed for ${endpoint.runtimeType} v$version, opcode ${endpoint.opcode}: $e',
      );
    }
  }

  @override
  Future<R> sendVersioned<R extends HlamTamResponse>(
    int version,
    List<EndpointFactory<R>> candidates,
  ) {
    final endpoint = _endpointSelector.pick(version, candidates);
    return send(endpoint);
  }
}
