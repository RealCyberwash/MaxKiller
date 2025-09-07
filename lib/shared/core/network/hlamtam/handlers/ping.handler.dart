import 'package:max_killer/shared/core/network/hlamtam/client.dart';
import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/handlers/handler.dart';
import 'package:max_killer/shared/core/network/hlamtam/packet.dart';

///
class PingHandler implements HlamTamHandler {
  @override
  Future<void> handle(HlamTamPacket packet, HlamTamClient client) async {
    await client.reply(packet, packet.data);
  }

  @override
  HlamTamOpcode get opcode => HlamTamOpcode.ping;
}
