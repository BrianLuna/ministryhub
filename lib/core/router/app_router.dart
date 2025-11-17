import 'package:go_router/go_router.dart';
import 'package:ministryhub/ministryhub.dart';

/// Application router configuration
class AppRouter {
  /// GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginRegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
