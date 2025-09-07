import 'package:max_killer/core/network/hlamtam/constants.dart';
import 'package:max_killer/core/network/hlamtam/packet.dart';

///
class HlamTamApiError implements Exception {
  ///
  HlamTamApiError({
    required this.code,
    this.message,
    this.localizedMessage,
    this.title,
    this.description,
    this.opcode,
    this.sequence,
    this.raw = const {},
  });

  ///
  factory HlamTamApiError.fromPacket(HlamTamPacket packet) {
    final data = packet.data;
    return HlamTamApiError(
      code: data['error']?.toString() ?? 'unknown',
      message: data['message']?.toString(),
      localizedMessage: data['localizedMessage']?.toString(),
      title: data['title']?.toString(),
      description: data['description']?.toString(),
      opcode: packet.opcode,
      sequence: packet.sequence,
      raw: Map<String, dynamic>.from(data),
    );
  }

  ///
  final String code;

  ///
  final String? message;

  ///
  final String? localizedMessage;

  ///
  final String? title;

  ///
  final String? description;

  ///
  final HlamTamOpcode? opcode;

  ///
  final int? sequence;

  ///
  final Map<String, dynamic> raw;

  ///
  String get displayText => localizedMessage?.trim().isNotEmpty == true
      ? localizedMessage!
      : (description?.trim().isNotEmpty == true
            ? description!
            : (message?.trim().isNotEmpty == true ? message! : code));

  ///
  String get displayTitle =>
      (title?.trim().isNotEmpty == true) ? title! : 'Ошибка';

  @override
  String toString() {
    return 'HlamTamApiError('
        'code=$code, '
        'message=$message, '
        'localizedMessage=$localizedMessage, '
        'title=$title, '
        'description=$description, '
        'opcode=$opcode, '
        'sequence=$sequence'
        ')';
  }
}
