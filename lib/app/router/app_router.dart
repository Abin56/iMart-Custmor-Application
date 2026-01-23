import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imart/features/navigation/main_navbar.dart';

import '../../features/auth/application/providers/auth_provider.dart';
import '../../features/auth/application/states/auth_state.dart';
import '../../features/auth/presentation/screen/splash_screen.dart';
import '../../features/auth/presentation/screen/welcome_name_screen.dart';
import '../../features/product_details/presentation/product_detail_screen.dart';

/// Notifier class to refresh GoRouter when auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen(authProvider, (prev, next) {
      notifyListeners();
    });
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshStream(ref);

  return GoRouter(
    // Start with splash screen which checks auth state
    initialLocation: '/splash',

    // Refresh router when auth state changes
    refreshListenable: refreshNotifier,

    // Redirect logic for protected routes
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authState = ref.read(authProvider);
      final isAuthenticated = authState is Authenticated;
      final isCheckingAuth = authState is AuthChecking;

      // Skip redirect while checking auth (let splash screen handle it)
      if (isCheckingAuth && location == '/splash') {
        return null;
      }

      // Protected routes that require authentication
      final protectedRoutes = ['/profile', '/account'];

      final isProtectedRoute = protectedRoutes.any(location.startsWith);

      // Auth routes (welcome name screen for post-login)
      final authRoutes = ['/welcome-name'];
      final isAuthRoute = authRoutes.any(location.startsWith);

      // If authenticated → block auth screens (redirect to home)
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // If not authenticated and trying to access protected routes → redirect to splash
      if (!isAuthenticated && !isCheckingAuth && isProtectedRoute) {
        return '/splash';
      }

      // Guest mode: Allow access to guest-accessible routes
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, state) =>
            MainNavigationShell(key: MainNavigationShell.globalKey),
      ),
      GoRoute(
        path: '/welcome-name',
        builder: (context, state) => const WelcomeNameScreen(),
      ),
      GoRoute(
        path: '/product/:variantId',
        builder: (context, state) {
          final variantId = int.parse(state.pathParameters['variantId']!);
          final imageUrl = state.uri.queryParameters['imageUrl'];
          return ProductDetailScreen(
            variantId: variantId,
            fallbackImageUrl: imageUrl,
          );
        },
      ),
    ],
  );
});

void goToHome(BuildContext context) {
  context.go('/home');
}

void goToWelcomeName(BuildContext context) {
  context.go('/welcome-name');
}
