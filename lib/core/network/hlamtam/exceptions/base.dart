/// Custom exception class for HlamTam network operations.
///
/// This exception is thrown when network-related errors occur during
/// communication with the HlamTam service.
class HlamTamException implements Exception {
  /// Creates a new HlamTamException with the specified error message.
  ///
  /// [message] The error message describing what went wrong
  HlamTamException(this.message);

  /// The error message describing the exception
  final String message;

  @override
  String toString() => 'HlamTamException: $message';
}
