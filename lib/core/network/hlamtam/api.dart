import 'package:max_killer/core/log.dart';
import 'package:max_killer/core/network/hlamtam/abstraction/response.dart';
import 'package:max_killer/core/network/hlamtam/services/auth/service.dart';

import 'client.dart';
import 'constants.dart';
import 'endpoints/endpoint.dart';
import 'exceptions/protocol.dart';

///
class HlamTamApi {
  ///
  HlamTamApi({required this.client, required this.version}) {
    auth = AuthServiceImpl(api: this, version: version);
  }

  ///
  final HlamTamClient client;

  ///
  final int version;

  ///
  late AuthService auth;

  ///
  Future<R> send<R extends Response>(Endpoint<R> endpoint) async {
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
}
