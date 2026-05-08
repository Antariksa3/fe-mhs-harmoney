import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SavingScreen extends StatelessWidget {
  const SavingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text('Saving Screen', style: AppTextStyles.headingMedium),
      ),
    );
  }
}
