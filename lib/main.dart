import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'features/home/presentation/screens/home_screen_complete.dart';
import 'features/newcart/presentation/navigation/main_navigation_shell.dart';

// Global container to access ProviderContainer
// late ProviderContainer _container;

Future<void> main() async {
  runApp(const MyApp());
  // await AppBootstrap.run(() async {
  //   final api = AppBootstrap.result.apiClient;

  //   _container = ProviderContainer(
  //     overrides: [
  //       dioProvider.overrideWithValue(api.dio),
  //       cookieJarProvider.overrideWithValue(api.cookieJar),
  //       apiClientProvider.overrideWithValue(api),
  //     ],
  //   );

  //   // Set the guest mode check function in ApiClient
  //   api.isGuestMode = () {
  //     final authState = _container.read(authProvider);
  //     return authState is GuestMode;
  //   };

  //   return UncontrolledProviderScope(
  //     container: _container,
  //     child: const MyApp(),
  //   );
  // });
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 return ScreenUtilInit(
      designSize: const Size(390, 835),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MaterialApp(
          home: MainNavigationShell(),
          debugShowCheckedModeBanner: false,
        
        );
      },
    );
  }
}

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // final router = ref.watch(goRouterProvider);

//     return ScreenUtilInit(
//       designSize: const Size(390, 835),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp.router(
//           debugShowCheckedModeBanner: false,
          // routerConfig: router,
          // theme: ThemeData(
          //   useMaterial3: true,
          //   progressIndicatorTheme: const ProgressIndicatorThemeData(
          //     color: AppColors.loaderGreen,
          //   ),
          //   fontFamily: 'Inter',
          //   textTheme: const TextTheme(
          //     displayLarge: TextStyle(fontFamily: 'Poppins'),
          //     displayMedium: TextStyle(fontFamily: 'Poppins'),
          //     displaySmall: TextStyle(fontFamily: 'Poppins'),

          //     headlineLarge: TextStyle(fontFamily: 'Poppins'),
          //     headlineMedium: TextStyle(fontFamily: 'Poppins'),
          //     headlineSmall: TextStyle(fontFamily: 'Poppins'),

          //     titleLarge: TextStyle(fontFamily: 'Poppins'),

          //     bodyLarge: TextStyle(),
          //     bodyMedium: TextStyle(),
          //     bodySmall: TextStyle(),

          //     labelLarge: TextStyle(),
          //     labelMedium: TextStyle(),
          //     labelSmall: TextStyle(),
          //   ),
          // ),
//         );
//       },
//     );
//   }
// }
