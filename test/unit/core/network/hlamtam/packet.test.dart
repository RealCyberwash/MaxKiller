import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:max_killer/core/network/hlamtam/constants.dart';
import 'package:max_killer/core/network/hlamtam/packet.dart';

void main() {
  test('decode START_AUTH packet', () {
    final hex = [
      0x0a,
      0x00,
      0x00,
      0x02,
      0x00,
      0x11,
      0x00,
      0x00,
      0x00,
      0x24,
      0x82,
      0xa5,
      0x70,
      0x68,
      0x6f,
      0x6e,
      0x65,
      0xac,
      0x2b,
      0x37,
      0x39,
      0x38,
      0x36,
      0x35,
      0x35,
      0x34,
      0x39,
      0x34,
      0x36,
      0x31,
      0xa4,
      0x74,
      0x79,
      0x70,
      0x65,
      0xaa,
      0x53,
      0x54,
      0x41,
      0x52,
      0x54,
      0x5f,
      0x41,
      0x55,
      0x54,
      0x48,
    ];

    final packet = HlamTamPacket.fromBytes(Uint8List.fromList(hex));

    expect(packet.version, 10);
    expect(packet.command, HlamTamCommand.request);
    expect(packet.sequence, 2);
    expect(packet.opcode, HlamTamOpcode.authRequest);

    expect(packet.data['phone'], '+79865549461');
    expect(packet.data['type'], 'START_AUTH');
  });

  test('encode + decode round trip', () {
    final original = HlamTamPacket(
      command: HlamTamCommand.request,
      sequence: 2,
      opcode: HlamTamOpcode.authRequest,
      data: {'phone': '+79865549461', 'type': 'START_AUTH'},
    );

    final encoded = original.toBytes();
    final decoded = HlamTamPacket.fromBytes(encoded);

    expect(decoded.version, original.version);
    expect(decoded.command, original.command);
    expect(decoded.sequence, original.sequence);
    expect(decoded.opcode, original.opcode);
    expect(decoded.data, original.data);
  });
}
