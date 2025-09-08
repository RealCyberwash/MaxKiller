import 'package:go_router/go_router.dart';
import 'package:max_killer/features/auth/presentation/register/register.page.dart';

///
final appRouter = GoRouter(
  initialLocation: '/auth/register',
  routes: [
    GoRoute(path: '/auth/register', builder: (_, __) => const RegisterPage()),
  ],
);
