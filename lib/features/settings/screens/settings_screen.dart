import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Settings', style: AppTextStyles.headingMedium),
      ),
      body: Center(
        child: Text('Settings Screen', style: AppTextStyles.headingMedium),
      ),
    );
  }
}
