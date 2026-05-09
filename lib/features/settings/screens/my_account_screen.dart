import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';

class MyAccountScreen extends ConsumerWidget {
  const MyAccountScreen({super.key});

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
        title: Text('My Account', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _AccountItem(
              label: 'Email',
              value: user?.email ?? '-',
              onTap: () => _showEditModal(
                context: context,
                ref: ref,
                title: 'Personal Account',
                fieldLabel: 'Email Address',
                initialValue: user?.email ?? '',
                onSave: (value) async {
                  await ref
                      .read(authProvider.notifier)
                      .updateProfile(email: value);
                },
              ),
            ),
            _AccountItem(
              label: 'Full Name',
              value: user?.fullName ?? '-',
              onTap: () => _showEditModal(
                context: context,
                ref: ref,
                title: 'Personal Account',
                fieldLabel: 'Full Name',
                initialValue: user?.fullName ?? '',
                onSave: (value) async {
                  await ref
                      .read(authProvider.notifier)
                      .updateProfile(fullName: value);
                },
              ),
            ),
            _AccountItem(
              label: 'Phone Number',
              value: user?.phoneNumber ?? '-',
              onTap: () => _showEditModal(
                context: context,
                ref: ref,
                title: 'Personal Account',
                fieldLabel: 'Phone Number',
                initialValue: user?.phoneNumber ?? '',
                keyboardType: TextInputType.phone,
                onSave: (value) async {
                  await ref
                      .read(authProvider.notifier)
                      .updateProfile(phoneNumber: value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditModal({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String fieldLabel,
    required String initialValue,
    required Future<void> Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditFieldModal(
        title: title,
        fieldLabel: fieldLabel,
        initialValue: initialValue,
        keyboardType: keyboardType,
        onSave: (value) async {
          await onSave(value);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$fieldLabel updated successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _AccountItem({
    required this.label,
    required this.value,
    required this.onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelLarge),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modal untuk edit field
class _EditFieldModal extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String initialValue;
  final TextInputType keyboardType;
  final Future<void> Function(String) onSave;

  const _EditFieldModal({
    required this.title,
    required this.fieldLabel,
    required this.initialValue,
    required this.keyboardType,
    required this.onSave,
  });

  @override
  State<_EditFieldModal> createState() => _EditFieldModalState();
}

class _EditFieldModalState extends State<_EditFieldModal> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await widget.onSave(_controller.text.trim());
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 28),
                Text(widget.title, style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Icon
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.cardBackground,
              child: Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 32,
              ),
            ),

            const SizedBox(height: 24),

            // Field
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.fieldLabel, style: AppTextStyles.labelLarge),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.initialValue,
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
