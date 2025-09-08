import 'package:freezed_annotation/freezed_annotation.dart';

part 'register.state.freezed.dart';

///
@freezed
abstract class RegisterState with _$RegisterState {
  ///
  const factory RegisterState({
    @Default('') String phone,
    @Default(false) bool isLoading,
  }) = _RegisterState;
}
