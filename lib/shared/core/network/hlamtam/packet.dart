import 'dart:typed_data';

import 'package:max_killer/shared/core/ffi/lz4.dart';
import 'package:pro_mpack/pro_mpack.dart';

import 'constants.dart';
import 'exceptions/base.dart';

///
typedef HlamTamTryParseResult = ({HlamTamPacket packet, int consumed});

///
class HlamTamPacket {
  ///
  HlamTamPacket({
    this.version = HlamTamTcp.protocolVersion,
    required this.command,
    required this.sequence,
    required this.opcode,
    required this.data,
  });

  ///
  factory HlamTamPacket.fromBytes(Uint8List bytes) {
    if (bytes.length < HlamTamTcp.headerSize) {
      throw HlamTamException('Packet too short');
    }

    final header = _headerView(bytes);

    final opcodeRaw = header.getUint16(4, Endian.big);
    final opcode = HlamTamOpcode.fromCode(opcodeRaw);
    if (opcode == null) {
      throw HlamTamException('Unknown opcode: $opcodeRaw');
    }

    final commandRaw = header.getUint8(1);
    final command = HlamTamCommand.fromCode(commandRaw);
    if (command == null) {
      throw HlamTamException('Unknown command: $commandRaw');
    }

    final version = header.getUint8(0);
    final sequence = header.getUint16(2, Endian.big);
    final (:compressionFlag, :payloadLength) = _readPayloadInfo(header);

    if (bytes.length < HlamTamTcp.headerSize + payloadLength) {
      throw HlamTamException(
        'Incomplete packet: expected ${HlamTamTcp.headerSize + payloadLength}, got ${bytes.length}',
      );
    }

    Map<String, dynamic> data = {};
    if (payloadLength > 0) {
      var payload = bytes.sublist(
        HlamTamTcp.headerSize,
        HlamTamTcp.headerSize + payloadLength,
      );

      if (compressionFlag > HlamTamTcp.noCompressionFlag) {
        final int dstCapacity = payload.length * compressionFlag;
        payload = lz4BlockDecompress(
          payload,
          dstCapacityHint: dstCapacity,
          maxOutputBytes: HlamTamTcp.maxDecompressedCap,
        );
      }

      try {
        final decoded = deserialize(payload);
        if (decoded is Map) {
          data = Map<String, dynamic>.fromEntries(
            decoded.entries.map((e) => MapEntry(e.key.toString(), e.value)),
          );
        } else {
          throw HlamTamException(
            'Unexpected payload root type: ${decoded.runtimeType}',
          );
        }
      } catch (e) {
        throw HlamTamException('Failed to decode MessagePack payload: $e');
      }
    }

    return HlamTamPacket(
      version: version,
      command: command,
      sequence: sequence,
      opcode: opcode,
      data: data,
    );
  }

  ///
  final int version;

  ///
  final HlamTamCommand command;

  ///
  final int sequence;

  ///
  final HlamTamOpcode opcode;

  ///
  final Map<String, dynamic> data;

  ///
  Uint8List toBytes() {
    final Uint8List rawPayload = data.isEmpty
        ? Uint8List(0)
        : Uint8List.fromList(serialize(data));

    int compressionFlag = HlamTamTcp.noCompressionFlag;
    Uint8List finalPayload = rawPayload;

    if (rawPayload.length >= HlamTamTcp.compressionThreshold) {
      final compressed = lz4BlockCompress(rawPayload);

      compressionFlag = ((rawPayload.length / compressed.length) + 1).floor();
      finalPayload = compressed;
    }

    final headerBytes = _encodeHeader(
      version: version,
      command: command.code,
      sequence: sequence,
      opcodeCode: opcode.code,
      compressionFlag: compressionFlag,
      payloadLength: finalPayload.length,
    );

    final result = Uint8List(HlamTamTcp.headerSize + finalPayload.length);
    result.setRange(0, HlamTamTcp.headerSize, headerBytes);
    if (finalPayload.isNotEmpty) {
      result.setRange(HlamTamTcp.headerSize, result.length, finalPayload);
    }

    return result;
  }

  @override
  String toString() {
    return 'HlamTamPacket(v=$version, seq=$sequence, cmd=$command, opcode=$opcode, data=$data)';
  }

  ///
  static HlamTamTryParseResult? tryParse(Uint8List bytes) {
    if (bytes.length < HlamTamTcp.headerSize) return null;

    final header = _headerView(bytes);
    final payloadLength = _readPayloadInfo(header).payloadLength;

    final totalLength = HlamTamTcp.headerSize + payloadLength;
    if (bytes.length < totalLength) return null;

    final packet = HlamTamPacket.fromBytes(bytes.sublist(0, totalLength));

    return (packet: packet, consumed: totalLength);
  }

  /// Returns a view of the header bytes. Caller must ensure [bytes] contains at least [HlamTamTcp.headerSize] bytes.
  static ByteData _headerView(Uint8List bytes) {
    return ByteData.sublistView(bytes, 0, HlamTamTcp.headerSize);
  }

  /// Reads compression flag and payload length from the header payload info field.
  static ({int compressionFlag, int payloadLength}) _readPayloadInfo(
    ByteData header,
  ) {
    final payloadInfo = header.getUint32(6, Endian.big);
    final compressionFlag = (payloadInfo >> 24) & 0xFF;
    final payloadLength = payloadInfo & 0xFFFFFF;
    return (compressionFlag: compressionFlag, payloadLength: payloadLength);
  }

  /// Encodes packet header into bytes to be prefixed before payload.
  static Uint8List _encodeHeader({
    required int version,
    required int command,
    required int sequence,
    required int opcodeCode,
    required int compressionFlag,
    required int payloadLength,
  }) {
    final header = ByteData(HlamTamTcp.headerSize);
    header.setUint8(0, version);
    header.setUint8(1, command);
    header.setUint16(2, sequence, Endian.big);
    header.setUint16(4, opcodeCode, Endian.big);
    header.setUint32(6, (compressionFlag << 24) | payloadLength, Endian.big);
    return header.buffer.asUint8List();
  }
}
