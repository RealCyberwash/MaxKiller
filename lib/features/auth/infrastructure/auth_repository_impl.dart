import 'package:max_killer/features/auth/domain/auth_repository.dart';
import 'package:max_killer/features/auth/domain/models/auth_request.dart';
import 'package:max_killer/shared/core/network/hlamtam/api.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/auth/auth_request/endpoint.rev1.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/auth/auth_request/response.rev1.dart';
import 'package:max_killer/shared/core/network/hlamtam/endpoints/auth/auth_request/types.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';

///
class AuthRepositoryImpl implements AuthRepository {
  ///
  AuthRepositoryImpl({required HlamTamApi api, required int version})
    : _api = api,
      _version = version;

  final HlamTamApi _api;
  final int _version;

  @override
  Future<AuthRequestModel> startAuth({required String phone}) async {
    final result = await _api.sendVersioned(_version, [
      () => AuthRequestRev1(phone: phone, type: AuthRequestType.startAuth),
    ]);

    return _mapAuthResponse(result);
  }

  @override
  Future<AuthRequestModel> resend({required String phone}) async {
    final result = await _api.sendVersioned(_version, [
      () => AuthRequestRev1(phone: phone, type: AuthRequestType.resend),
    ]);

    return _mapAuthResponse(result);
  }

  AuthRequestModel _mapAuthResponse(HlamTamResponse response) {
    if (response is AuthRequestResponseRev1) {
      return AuthRequestModel(
        token: response.token,
        codeLength: response.codeLength,
        requestMaxDuration: Duration(seconds: response.requestMaxDuration),
        requestCountLeft: response.requestCountLeft,
        altActionDuration: Duration(seconds: response.altActionDuration),
      );
    }
    throw StateError('Unknown auth response revision: ${response.runtimeType}');
  }
}
