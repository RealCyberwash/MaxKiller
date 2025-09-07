import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:max_killer/shared/core/network/hlamtam/response.dart';
import 'package:max_killer/shared/core/serialization/int_from_any_converter.dart';

part 'response.rev1.freezed.dart';
part 'response.rev1.g.dart';

///
@freezed
abstract class AuthRequestResponseRev1
    with _$AuthRequestResponseRev1
    implements HlamTamResponse {
  ///
  const factory AuthRequestResponseRev1({
    required String token,
    @IntFromAnyConverter() required int codeLength,
    @IntFromAnyConverter() required int requestMaxDuration,
    @IntFromAnyConverter() required int requestCountLeft,
    @IntFromAnyConverter() required int altActionDuration,
  }) = _AuthRequestResponseRev1;

  ///
  factory AuthRequestResponseRev1.fromMap(Map<String, dynamic> map) =>
      _$AuthRequestResponseRev1FromJson(map);
}
