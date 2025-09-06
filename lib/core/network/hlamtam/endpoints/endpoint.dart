import 'package:max_killer/core/network/hlamtam/abstraction/response.dart';
import 'package:max_killer/core/network/hlamtam/constants.dart';

///
abstract interface class Endpoint<R extends Response> {
  ///
  HlamTamOpcode get opcode;

  ///
  Map<String, dynamic> toPayload();

  ///
  R fromPayload(Map<String, dynamic> map);

  ///
  bool supports(int protocolVersion);
}
