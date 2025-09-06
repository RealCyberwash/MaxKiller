import 'package:max_killer/core/network/hlamtam/client.dart';
import 'package:max_killer/core/network/hlamtam/constants.dart';
import 'package:max_killer/core/network/hlamtam/packet.dart';

///
abstract class HlamTamHandler {
  ///
  HlamTamOpcode get opcode;

  ///
  Future<void> handle(HlamTamPacket packet, HlamTamClient client);
}
