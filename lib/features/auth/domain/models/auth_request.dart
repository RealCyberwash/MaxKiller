import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request.freezed.dart';

///
@freezed
abstract class AuthRequestModel with _$AuthRequestModel {
  ///
  const factory AuthRequestModel({
    required String token,
    required int codeLength,
    required Duration requestMaxDuration,
    required int requestCountLeft,
    required Duration altActionDuration,
  }) = _AuthRequestModel;
}
