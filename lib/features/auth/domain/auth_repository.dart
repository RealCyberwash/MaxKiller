import 'models/auth_request.dart';

///
abstract interface class AuthRepository {
  ///
  Future<AuthRequestModel> startAuth({required String phone});

  ///
  Future<AuthRequestModel> resend({required String phone});
}
