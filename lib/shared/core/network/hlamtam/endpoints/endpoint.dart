import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';

///
typedef EndpointFactory<R extends HlamTamResponse> = Endpoint<R> Function();

///
abstract interface class Endpoint<R extends HlamTamResponse> {
  ///
  HlamTamOpcode get opcode;

  ///
  Map<String, dynamic> toPayload();

  ///
  R fromPayload(Map<String, dynamic> map);

  ///
  bool supports(int protocolVersion);
}
