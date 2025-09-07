import 'package:max_killer/shared/core/network/hlamtam/response.dart';

///
class AuthRequestResponseRev1 implements HlamTamResponse {
  ///
  const AuthRequestResponseRev1({
    required this.token,
    required this.codeLength,
    required this.requestMaxDuration,
    required this.requestCountLeft,
    required this.altActionDuration,
  });

  ///
  factory AuthRequestResponseRev1.fromMap(Map<String, dynamic> m) {
    return AuthRequestResponseRev1(
      token: m['token'] as String,
      codeLength: m['codeLength'] as int,
      requestMaxDuration: m['requestMaxDuration'] as int,
      requestCountLeft: m['requestCountLeft'] as int,
      altActionDuration: m['altActionDuration'] as int,
    );
  }

  ///
  final String token;

  ///
  final int codeLength;

  ///
  final int requestMaxDuration;

  ///
  final int requestCountLeft;

  ///
  final int altActionDuration;
}
