import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/providers/auth_provider.dart';
import '../../features/auth/application/states/auth_state.dart';
import '../../features/auth/presentation/screen/splash_screen.dart';
import '../../features/auth/presentation/screen/welcome_name_screen.dart';
import '../../features/bottomnavbar/bottom_navbar.dart';
import '../../features/cart/presentation/screen/cart_screen.dart';
import '../../features/cart/presentation/screen/confirm_order_screen.dart';
import '../../features/cart/presentation/screen/failed_order_screen.dart';
import '../../features/address/presentation/screens/address_list_screen.dart';
import '../../features/home/presentation/screen/categories_with_sidebar_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/product_details/presentation/screen/product_details_screen.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';

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

      // Protected routes that require authentication (guests will be redirected to OTP)
      final protectedRoutes = [
        '/cart',
        '/checkout',
        '/profile',
        '/orders',
        '/account',
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => location.startsWith(route),
      );

      // Auth routes (welcome name screen for post-login)
      final authRoutes = [
        '/welcome-name',
      ];
      final isAuthRoute = authRoutes.any((route) => location.startsWith(route));

      // If authenticated → block auth screens (redirect to home)
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // If not authenticated and trying to access protected routes → redirect to splash
      if (!isAuthenticated && !isCheckingAuth && isProtectedRoute) {
        return '/splash';
      }

      // Guest mode: Allow access to guest-accessible routes
      // (no redirect needed for /home, /product-details, /category-products)

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
            BottomNavigation(key: BottomNavigation.globalKey),
      ),
      GoRoute(path: '/cart', builder: (_, state) => const CartScreen()),
      GoRoute(path: '/orders', builder: (_, state) => const OrdersScreen()),
      GoRoute(
        path: '/order-success',
        builder: (_, state) => const ConfirmOrderScreen(),
      ),
      GoRoute(
        path: '/order-failed',
        builder: (_, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            return FailedOrderScreen(
              errorMessage: extra['error']?.toString(),
              isReservationExpired: extra['isReservationExpired'] == true,
            );
          }
          return const FailedOrderScreen();
        },
      ),
      GoRoute(path: '/profile', builder: (_, state) => const ProfileScreen()),
      GoRoute(
        path: '/address-list',
        builder: (_, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/product-details/:variantId',
        builder: (context, state) {
          final variantId = state.pathParameters['variantId'] ?? '';
          return ProductDetailsScreen(variantId: variantId);
        },
      ),

      GoRoute(
        path: '/category-products',
        builder: (context, state) => const CategoriesWithSidebarScreen(),
      ),
      GoRoute(
        path: '/welcome-name',
        builder: (context, state) => const WelcomeNameScreen(),
      ),
    ],
  );
});

void goToHome(BuildContext context) {
  context.go('/home');
}

void goToOrders(BuildContext context) {
  context.push('/orders');
}

void goToWelcomeName(BuildContext context) {
  context.go('/welcome-name');
}
