/// Network commands used for communication with HlamTam service.
enum HlamTamOpcode {
  /// Ping command to check server availability
  ping(1),

  /// Debug command for development and troubleshooting
  debug(2),

  /// Reconnection command to re-establish connection
  reconnect(3),

  /// Log command for logging operations
  log(5),

  /// Session initialization command
  sessionInit(6),

  /// Profile management command
  profile(16),

  /// Authentication request command
  authRequest(17),

  /// Authentication command
  auth(18),

  /// User login command
  login(19),

  /// User logout command
  logout(20),

  /// Data synchronization command
  sync(21),

  /// Configuration management command
  config(22),

  /// Authentication confirmation command
  authConfirm(23);

  const HlamTamOpcode(this.code);

  /// Code of the command
  final int code;

  ///
  static HlamTamOpcode? fromCode(int code) {
    for (final value in HlamTamOpcode.values) {
      if (value.code == code) return value;
    }
    return null;
  }
}

///
enum HlamTamCommand {
  ///
  request(0),

  ///
  response(1);

  const HlamTamCommand(this.code);

  /// Code of the command
  final int code;

  ///
  static HlamTamCommand? fromCode(int code) {
    for (final value in HlamTamCommand.values) {
      if (value.code == code) return value;
    }
    return null;
  }
}

/// TCP connection configuration.
///
/// Contains network protocol settings and connection parameters.
class HlamTamTcp {
  /// Default port for HTTPS connections
  static const int port = 443;

  /// Protocol version number (5-10)
  static const int protocolVersion = 10;

  /// Size of the message header in bytes
  static const int headerSize = 10;

  /// Minimum data size threshold for compression (bytes)
  static const int compressionThreshold = 32;

  /// Flag indicating no compression should be used
  static const int noCompressionFlag = 0;

  /// 32 MB
  static const maxDecompressedCap = 32 * 1024 * 1024;
}

/// Available domains/environments.
///
/// Different domains represent different deployment environments.
enum HlamTamDomain {
  /// Production environment
  production('api.oneme.ru'),

  /// Test environment
  test('api-test.oneme.ru'),

  /// Second test environment
  testTwo('api-test2.oneme.ru'),

  /// Telegram-specific environment
  tg('api-tg.oneme.ru');

  const HlamTamDomain(this.host);

  /// Host URL for the domain
  final String host;
}
