///
class AuthRequestModel {
  ///
  const AuthRequestModel({
    required this.token,
    required this.codeLength,
    required this.requestMaxDuration,
    required this.requestCountLeft,
    required this.altActionDuration,
  });

  ///
  final String token;

  ///
  final int codeLength;

  ///
  final Duration requestMaxDuration;

  ///
  final int requestCountLeft;

  ///
  final Duration altActionDuration;
}
