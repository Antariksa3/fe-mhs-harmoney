import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _step = 1; // 1 = current password, 2 = new password
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_step == 1) {
      if (_currentPasswordController.text.isEmpty) {
        _showError('Please enter your current password');
        return;
      }
      // Validasi current password lewat mock
      setState(() => _isLoading = true);
      try {
        // Coba change dengan password dummy untuk validasi
        // Di real app ini pakai endpoint verify-password
        await Future.delayed(const Duration(milliseconds: 600));
        setState(() {
          _step = 2;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        _showError('Current password is incorrect');
      }
      return;
    }

    // Step 2: submit new password
    if (_newPasswordController.text.isEmpty) {
      _showError('Please enter new password');
      return;
    }
    if (_newPasswordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showError('Current password is incorrect');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // back to settings
                  },
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ),

              const SizedBox(height: 8),

              // Checkmark
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 36,
                ),
              ),

              const SizedBox(height: 20),

              Text('Password Reset', style: AppTextStyles.headingLarge),

              const SizedBox(height: 12),

              Text(
                'Your Password has been reset\nSuccessfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (_step == 2) {
              setState(() => _step = 1);
            } else {
              Navigator.pop(context);
            }
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          _step == 1 ? 'Reset Password' : 'New Password',
          style: AppTextStyles.headingMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            if (_step == 1) ...[
              // Step 1: current password
              Text('Current Password', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                hint: 'Enter your password',
                controller: _currentPasswordController,
                isPassword: true,
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'To change your password, you need to enter your current password first.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Step 2: new password
              Text('New Password', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                hint: 'Enter your password',
                controller: _newPasswordController,
                isPassword: true,
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text('Confirm New Password', style: AppTextStyles.labelLarge),
              const SizedBox(height: 12),
              AppTextField(
                label: '',
                hint: 'Enter your password',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            const Spacer(),

            AppButton(
              label: _step == 1 ? 'Next' : 'Submit',
              isLoading: _isLoading,
              onPressed: _handleNext,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
