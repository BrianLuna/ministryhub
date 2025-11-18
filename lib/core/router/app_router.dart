import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ministryhub/ministryhub.dart';

/// Application router configuration
class AppRouter {
  /// GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authControllerProvider);
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      // If user is authenticated and trying to go to login, redirect to home
      if (isAuthenticated && isGoingToLogin) {
        return '/home';
      }

      // If user is not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      return null;
    },
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
