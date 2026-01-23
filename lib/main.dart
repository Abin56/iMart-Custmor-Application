import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imart/app/bootstrap/app_bootstrap.dart';
import 'package:imart/app/core/network/api_client.dart';
import 'package:imart/app/core/providers/network_providers.dart';

import 'app/router/app_router.dart';
import 'app/theme/colors.dart';
import 'features/auth/application/providers/auth_provider.dart';
import 'features/auth/application/states/auth_state.dart';
import 'features/cart/application/controllers/cart_controller.dart';
import 'features/wishlist/application/providers/wishlist_providers.dart';

// Global container to access ProviderContainer
late ProviderContainer _container;

Future<void> main() async {
  await AppBootstrap.run(() async {
    final api = AppBootstrap.result.apiClient;

    _container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(api.dio),
        cookieJarProvider.overrideWithValue(api.cookieJar),
        apiClientProvider.overrideWithValue(api),
      ],
    );

    // Set the guest mode check function in ApiClient
    api.isGuestMode = () {
      final authState = _container.read(authProvider);
      return authState is GuestMode;
    };

    // Preload wishlist and cart for faster app startup
    // This loads data in the background while the app is initializing
    _preloadAppData();

    return UncontrolledProviderScope(
      container: _container,
      child: const MyApp(),
    );
  });
}

/// Preload app data in the background for faster user experience
/// Loads wishlist and cart data as soon as the app starts
void _preloadAppData() {
  // Run in a microtask to not block the UI thread
  Future.microtask(() async {
    try {
      // Check if user is authenticated (not in guest mode)
      final authState = _container.read(authProvider);
      if (authState is! GuestMode) {
        // Preload wishlist - accessing the provider triggers auto-load
        _container.read(wishlistProvider);

        // Preload cart
        await _container.read(cartControllerProvider.notifier).loadCart();
      } else {}
    } catch (e) {
      // Non-critical error - app will load data when needed
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 835),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: AppColors.loaderGreen,
            ),
            fontFamily: 'Inter',
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontFamily: 'Poppins'),
              displayMedium: TextStyle(fontFamily: 'Poppins'),
              displaySmall: TextStyle(fontFamily: 'Poppins'),

              headlineLarge: TextStyle(fontFamily: 'Poppins'),
              headlineMedium: TextStyle(fontFamily: 'Poppins'),
              headlineSmall: TextStyle(fontFamily: 'Poppins'),

              titleLarge: TextStyle(fontFamily: 'Poppins'),

              bodyLarge: TextStyle(),
              bodyMedium: TextStyle(),
              bodySmall: TextStyle(),

              labelLarge: TextStyle(),
              labelMedium: TextStyle(),
              labelSmall: TextStyle(),
            ),
          ),
        );
      },
    );
  }
}
