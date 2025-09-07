import 'dart:ffi';
import 'dart:io';

import 'package:path/path.dart';

/// Opens a native library (DynamicLibrary) based on the current platform and architecture.
///
/// This function handles cross-platform native library loading by:
/// 1. Determining the appropriate library file extension for the current OS
/// 2. Searching for the library in platform-specific build directories
/// 3. Falling back to system-specific loading mechanisms
///
/// [baseName] The base name of the native library (without extension)
///
/// Returns a [DynamicLibrary] instance that can be used for FFI calls.
///
/// Platform-specific behavior:
/// - **iOS**: Returns [DynamicLibrary.process()] directly
/// - **Windows**: Searches in windows-x64 and windows-arm64 directories
/// - **Linux**: Searches in linux-x86_64, linux-aarch64, and linux-arm64 directories
/// - **macOS**: Searches in macos-universal, macos-arm64, and macos-x86_64 directories,
///   with fallback to Frameworks directory and process loading
/// - **Android**: Uses Linux-style loading with .so extension
DynamicLibrary openNative(String baseName) {
  if (Platform.isIOS) return DynamicLibrary.process();

  final os = Platform.operatingSystem;
  final name = switch (os) {
    'windows' => '$baseName.dll',
    'linux' => 'lib$baseName.so',
    'android' => 'lib$baseName.so',
    _ => 'lib$baseName.dylib', // macOS
  };

  final base = join(Directory.current.path, 'build', 'native');
  final candidates = <String>[
    if (Platform.isWindows)
      ...['x64', 'arm64'].map((arch) => join(base, 'windows-$arch', name)),
    if (Platform.isLinux)
      ...[
        'x86_64',
        'aarch64',
        'arm64',
      ].map((arch) => join(base, 'linux-$arch', name)),
    if (Platform.isMacOS)
      ...[
        'universal',
        'arm64',
        'x86_64',
      ].map((arch) => join(base, 'macos-$arch', name)),
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) {
      return DynamicLibrary.open(path);
    }
  }

  if (Platform.isMacOS) {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final fw = normalize(join(exeDir, '../Frameworks', name));
    if (File(fw).existsSync()) return DynamicLibrary.open(fw);

    return DynamicLibrary.process();
  }

  return DynamicLibrary.open(name);
}
