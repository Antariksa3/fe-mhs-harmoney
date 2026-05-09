import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/sign_in_screen.dart';
import 'manage_wallet_screen.dart';
import 'my_account_screen.dart';
import 'change_password_screen.dart';
import 'manage_category_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text('Settings', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.cardBackground,
                        child: Icon(
                          Icons.person_outline,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'User',
                    style: AppTextStyles.headingMedium,
                  ),
                  Text(user?.email ?? '', style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.person_outline,
                    label: 'My Account',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyAccountScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.label_outline,
                    label: 'Manage Category',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageCategoryScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Manage Wallet',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageWalletScreen(),
                        ),
                      );
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.description_outlined,
                    label: 'Manage Report',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.currency_exchange_outlined,
                    label: 'Manage Currency',
                    onTap: () {},
                  ),
                  _SettingsItem(
                    icon: Icons.refresh_rounded,
                    label: 'Reset Data',
                    iconColor: AppColors.error,
                    labelColor: AppColors.error,
                    onTap: () => _showResetDataDialog(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Log Out
            GestureDetector(
              onTap: () => _showLogoutDialog(context, ref),
              child: Text(
                'Log Out',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Text('Version 1.0.0', style: AppTextStyles.bodySmall),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure want to log out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Log Out',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Data', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to reset all data? This action cannot be undone.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Reset Data',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: labelColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: labelColor ?? AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
