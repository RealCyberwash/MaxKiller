import 'package:max_killer/shared/core/network/hlamtam/constants.dart';
import 'package:max_killer/shared/core/network/hlamtam/operations/auth/auth_request/response.rev1.dart';
import 'package:max_killer/shared/core/network/hlamtam/operations/auth/auth_request/types.dart';
import 'package:max_killer/shared/core/network/hlamtam/operations/operation.dart';

///
class AuthRequestOperationRev1
    implements HlamTamOperation<AuthRequestResponseRev1> {
  ///
  const AuthRequestOperationRev1({required this.phone, required this.type});

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
      AuthRequestResponseRev1.fromJson(map);

  @override
  bool supports(int protocolVersion) => protocolVersion >= 10;
}
