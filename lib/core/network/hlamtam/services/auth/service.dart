import 'package:max_killer/core/network/hlamtam/abstraction/response.dart';
import 'package:max_killer/core/network/hlamtam/api.dart';
import 'package:max_killer/core/network/hlamtam/endpoints/auth/auth_request/endpoint.rev1.dart';
import 'package:max_killer/core/network/hlamtam/endpoints/auth/auth_request/response.rev1.dart';
import 'package:max_killer/core/network/hlamtam/endpoints/auth/auth_request/types.dart';
import 'package:max_killer/core/network/hlamtam/services/auth/models/auth_request.model.dart';
import 'package:max_killer/core/network/hlamtam/services/versioning.dart';

///
abstract interface class AuthService {
  ///
  Future<AuthRequestModel> startAuth({required String phone});

  ///
  Future<AuthRequestModel> resend({required String phone});
}

///
class AuthServiceImpl implements AuthService {
  ///
  AuthServiceImpl({required HlamTamApi api, required int version})
    : _api = api,
      _version = version;

  final HlamTamApi _api;
  final int _version;

  @override
  Future<AuthRequestModel> startAuth({required String phone}) async {
    final res = await _sendAuthRequest(
      phone: phone,
      type: AuthRequestType.startAuth,
      candidates: [
        () => AuthRequestRev1(phone: phone, type: AuthRequestType.startAuth),
      ],
    );
    return _mapAuthResponse(res);
  }

  @override
  Future<AuthRequestModel> resend({required String phone}) async {
    final res = await _sendAuthRequest(
      phone: phone,
      type: AuthRequestType.resend,
      candidates: [
        () => AuthRequestRev1(phone: phone, type: AuthRequestType.resend),
      ],
    );
    return _mapAuthResponse(res);
  }

  Future<Response> _sendAuthRequest({
    required String phone,
    required AuthRequestType type,
    required List<AnyEndpointFactory> candidates,
  }) async {
    final endpoint = pickAnyEndpointByVersion(_version, candidates);
    return _api.send(endpoint);
  }

  AuthRequestModel _mapAuthResponse(Response res) {
    if (res is AuthRequestResponseRev1) {
      return AuthRequestModel(
        token: res.token,
        codeLength: res.codeLength,
        requestMaxDuration: Duration(seconds: res.requestMaxDuration),
        requestCountLeft: res.requestCountLeft,
        altActionDuration: Duration(seconds: res.altActionDuration),
      );
    }
    throw StateError('Unknown auth response revision: ${res.runtimeType}');
  }
}
