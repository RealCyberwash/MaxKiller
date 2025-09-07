import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'open.dart';

/// C-style function signature for LZ4_compressBound.
///
/// Returns the maximum compressed size for a given input size.
typedef Lz4CompressBoundC = Int32 Function(Int32);

/// C-style function signature for LZ4_compress_default.
///
/// Compresses input data using LZ4 algorithm with default settings.
typedef Lz4CompressDefaultC =
    Int32 Function(Pointer<Uint8>, Pointer<Uint8>, Int32, Int32);

/// C-style function signature for LZ4_decompress_safe.
///
/// Safely decompresses LZ4 compressed data.
typedef Lz4DecompressSafeC =
    Int32 Function(Pointer<Uint8>, Pointer<Uint8>, Int32, Int32);

/// Dart-style function signature for LZ4_compressBound.
///
/// Returns the maximum compressed size for a given input size.
typedef Lz4CompressBoundD = int Function(int);

/// Dart-style function signature for LZ4_compress_default.
///
/// Compresses input data using LZ4 algorithm with default settings.
typedef Lz4CompressDefaultD =
    int Function(Pointer<Uint8>, Pointer<Uint8>, int, int);

/// Dart-style function signature for LZ4_decompress_safe.
///
/// Safely decompresses LZ4 compressed data.
typedef Lz4DecompressSafeD =
    int Function(Pointer<Uint8>, Pointer<Uint8>, int, int);

final _lib = openNative('lz4shim');

final _lz4CompressBound = _lib
    .lookupFunction<Lz4CompressBoundC, Lz4CompressBoundD>('LZ4_compressBound');

final _lz4Compress = _lib
    .lookupFunction<Lz4CompressDefaultC, Lz4CompressDefaultD>(
      'LZ4_compress_default',
    );

final _lz4Decompress = _lib
    .lookupFunction<Lz4DecompressSafeC, Lz4DecompressSafeD>(
      'LZ4_decompress_safe',
    );

/// Compresses input data using LZ4 algorithm.
///
/// This function compresses the input byte array using LZ4 compression.
/// It automatically allocates memory for the output and handles cleanup.
///
/// [input] The input data to compress
///
/// Returns a compressed byte array. If input is empty, returns an empty array.
///
/// Throws an [Exception] if compression fails.
Uint8List lz4BlockCompress(Uint8List input) {
  if (input.isEmpty) return Uint8List(0);
  final arena = Arena();

  try {
    final src = arena<Uint8>(input.length);
    src.asTypedList(input.length).setAll(0, input);
    final outCap = _lz4CompressBound(input.length);
    final dst = arena<Uint8>(outCap);

    final outSize = _lz4Compress(src, dst, input.length, outCap);
    if (outSize <= 0) throw Exception('LZ4 compress failed ($outSize)');

    return Uint8List.fromList(dst.asTypedList(outSize));
  } finally {
    arena.releaseAll();
  }
}

/// Decompresses LZ4 compressed data.
///
/// Decompresses a single LZ4 block into an output buffer. You must provide a
/// capacity hint for the destination buffer; if the hint is too small, the
/// call fails. Optionally, you can set [maxOutputBytes] as a hard upper bound
/// to validate [dstCapacityHint].
///
/// [compressed] The compressed input bytes.
/// [dstCapacityHint] Expected decompressed size used to allocate the buffer.
/// [maxOutputBytes] Optional hard limit; [dstCapacityHint] must not exceed it.
///
/// Returns the decompressed bytes. For empty input, returns an empty array.
///
/// Throws [Exception] if parameters are invalid or decompression fails.
Uint8List lz4BlockDecompress(
  Uint8List compressed, {
  required int dstCapacityHint,
  int? maxOutputBytes,
}) {
  if (compressed.isEmpty) return Uint8List(0);

  if (dstCapacityHint <= 0 ||
      (maxOutputBytes != null && dstCapacityHint > maxOutputBytes)) {
    throw Exception(
      'Unreasonable LZ4 output cap: $dstCapacityHint (max: $maxOutputBytes)',
    );
  }

  final arena = Arena();
  final src = arena<Uint8>(compressed.length);
  final dst = arena<Uint8>(dstCapacityHint);
  try {
    src.asTypedList(compressed.length).setAll(0, compressed);

    final outSize = _lz4Decompress(
      src,
      dst,
      compressed.length,
      dstCapacityHint,
    );

    if (outSize < 0) {
      throw Exception('LZ4 decompress failed ($outSize)');
    }

    return Uint8List.fromList(dst.asTypedList(outSize));
  } finally {
    arena.releaseAll();
  }
}
