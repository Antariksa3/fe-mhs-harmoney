import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),

              // Illustration placeholder
              // Center(
              //   child: Container(
              //     width: 220,
              //     height: 220,
              //     decoration: BoxDecoration(
              //       color: AppColors.cardBackground,
              //       borderRadius: BorderRadius.circular(32),
              //     ),
              //     child: Icon(
              //       Icons.account_balance_wallet_rounded,
              //       size: 100,
              //       color: AppColors.primary,
              //     ),
              //   ),
              // ),
              const Spacer(flex: 2),

              // Text
              Text(
                'Where Money\nFinds Its Balance.',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A simpler way to understand, control, and\nlive in harmony with your money, every\nsingle day.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 40),

              AppButton(
                label: 'Get Started →',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
