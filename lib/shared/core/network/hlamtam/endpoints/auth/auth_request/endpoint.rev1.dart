import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/auth/auth_request/response.rev1.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/auth/auth_request/types.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/endpoint.dart';

///
class AuthRequestRev1 implements Endpoint<AuthRequestResponseRev1> {
  ///
  const AuthRequestRev1({required this.phone, required this.type});

  ///
  final String phone;

  ///
  final AuthRequestType type;

  @override
  HlamTamOpcode get opcode => HlamTamOpcode.authRequest;

  @override
  Map<String, dynamic> toPayload() => {'phone': phone, 'type': type.value};

  @override
  AuthRequestResponseRev1 fromPayload(Map<String, dynamic> map) =>
      AuthRequestResponseRev1.fromMap(map);

  @override
  bool supports(int protocolVersion) => protocolVersion >= 10;
}
