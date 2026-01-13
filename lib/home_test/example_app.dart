import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'complete_home_screen.dart';

/// Example app demonstrating the complete home screen
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'iMart - Grocery App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF0D5C2E),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Poppins',
          ),
          home: const CompleteHomeScreen(),
        );
      },
    );
  }
}

/// To use this, update your main.dart:
///
/// import 'home_test/example_app.dart';
///
/// void main() {
///   runApp(const ExampleApp());
/// }
