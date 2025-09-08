import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:max_killer/app/router.dart';
import 'package:max_killer/features/auth/domain/auth_repository.dart';

import 'di.dart';

///
class MaxKillerApp extends StatelessWidget {
  ///
  const MaxKillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: di<AuthRepository>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(useMaterial3: true),
      ),
    );
  }
}
