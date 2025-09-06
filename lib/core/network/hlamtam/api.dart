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
      throw StateError(
        'Endpoint ${endpoint.runtimeType} does not support the protocol v$version',
      );
    }

    final packet = await client.send(
      HlamTamCommand.request,
      endpoint.opcode,
      endpoint.toPayload(),
    );
    final data = packet.data;

    if (data['error'] != null) {
      throw ProtocolError(
        code: data['error'] as String,
        message: (data['message'] as String?) ?? 'Unknown error',
        packet: packet,
      );
    }

    try {
      return endpoint.fromPayload(data);
    } on Object catch (e) {
      throw StateError(
        'Parse failed for ${endpoint.runtimeType} v$version, opcode ${endpoint.opcode}: $e',
      );
    }
  }
}
