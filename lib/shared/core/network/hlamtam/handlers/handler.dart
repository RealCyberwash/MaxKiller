import 'package:max_killer/shared/core/network/hlamtam/client.dart';
import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/packet.dart';

///
abstract class HlamTamHandler {
  ///
  HlamTamOpcode get opcode;

  ///
  Future<void> handle(HlamTamPacket packet, HlamTamClient client);
}
