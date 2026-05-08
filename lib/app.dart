import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'features/auth/screens/splash_screen.dart';

class HarmoneyApp extends ConsumerWidget {
  const HarmoneyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Harmoney',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'PlusJakartaSans',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
