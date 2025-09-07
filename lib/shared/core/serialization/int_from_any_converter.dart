import 'package:freezed_annotation/freezed_annotation.dart';

///
class IntFromAnyConverter implements JsonConverter<int, Object?> {
  ///
  const IntFromAnyConverter();

  @override
  int fromJson(Object? value) {
    if (value == null) throw ArgumentError('null int');
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);

    return throw ArgumentError(
      'Unsupported int: $value (${value.runtimeType})',
    );
  }

  @override
  Object toJson(int value) => value;
}
