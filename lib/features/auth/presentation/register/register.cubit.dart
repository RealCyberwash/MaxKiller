import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:max_killer/features/auth/domain/auth_repository.dart';

import 'register.state.dart';

///
class RegisterCubit extends Cubit<RegisterState> {
  ///
  RegisterCubit(this._auth) : super(const RegisterState());

  final AuthRepository _auth;

  ///
  void onPhoneChanged(String v) => emit(state.copyWith(phone: v));

  ///
  Future<void> submit() async {
    print(state.phone);
    final result = await _auth.startAuth(phone: state.phone);
    print(result);
  }
}
