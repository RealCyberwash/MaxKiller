import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:max_killer/features/auth/domain/auth_repository.dart';
import 'package:max_killer/features/auth/presentation/register/register.cubit.dart';
import 'package:max_killer/features/auth/presentation/register/register.state.dart';

///
class RegisterPage extends StatelessWidget {
  ///
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(context.read<AuthRepository>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Телефон'),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.phone,
                  onChanged: cubit.onPhoneChanged,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '+79991234567',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => cubit.submit(),
                  child: const Text('Продолжить'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
