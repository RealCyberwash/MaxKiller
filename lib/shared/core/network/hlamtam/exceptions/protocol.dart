import 'package:max_killer/shared/core/network/hlamtam/packet.dart';

import 'base.dart';

///
class ProtocolError implements HlamTamException {
  ///
  const ProtocolError({required this.code, required this.message, this.packet});

  ///
  final String code;

  ///
  @override
  final String message;

  ///
  final HlamTamPacket? packet;

  @override
  String toString() => 'ProtocolError($code): $message';
}
