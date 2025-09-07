///
enum AuthRequestType {
  ///
  startAuth('START_AUTH'),

  ///
  resend('RESEND');

  const AuthRequestType(this.value);

  ///
  final String value;
}
