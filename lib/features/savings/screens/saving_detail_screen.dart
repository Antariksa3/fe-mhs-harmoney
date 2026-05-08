import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/saving_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../home/providers/home_provider.dart';
import 'create_saving_screen.dart';

class SavingDetailScreen extends ConsumerWidget {
  final SavingModel saving;

  const SavingDetailScreen({super.key, required this.saving});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final progress = saving.progressPercentage / 100;
    final daysLeft = saving.daysLeft;
    final isOverdue = daysLeft < 0;
    final remaining = saving.targetAmount - saving.currentAmount;

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
        title: Text('Saving Detail', style: AppTextStyles.headingMedium),
        centerTitle: true,
        actions: [
          // Edit button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateSavingScreen(existingSaving: saving),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Main card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.savings_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  Text(saving.name, style: AppTextStyles.headingLarge),
                  const SizedBox(height: 8),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppColors.error.withOpacity(0.1)
                          : progress >= 1.0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOverdue
                          ? 'Overdue'
                          : progress >= 1.0
                          ? 'Completed!'
                          : '$daysLeft Days Left',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverdue
                            ? AppColors.error
                            : progress >= 1.0
                            ? AppColors.success
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? AppColors.success : AppColors.primary,
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress percentage
                  Text(
                    '${saving.progressPercentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Amount details
                  Row(
                    children: [
                      Expanded(
                        child: _AmountInfo(
                          label: 'Saved',
                          amount: currencyFormat.format(saving.currentAmount),
                          color: AppColors.income,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      Expanded(
                        child: _AmountInfo(
                          label: 'Target',
                          amount: currencyFormat.format(saving.targetAmount),
                          color: AppColors.primary,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      Expanded(
                        child: _AmountInfo(
                          label: 'Remaining',
                          amount: currencyFormat.format(
                            remaining > 0 ? remaining : 0,
                          ),
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Start Date',
                    value: DateFormat('MMMM dd, yyyy').format(saving.startDate),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'End Date',
                    value: DateFormat('MMMM dd, yyyy').format(saving.endDate),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Duration',
                    value:
                        '${saving.endDate.difference(saving.startDate).inDays} days',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Delete button
            AppButton(
              label: 'Delete Goal',
              backgroundColor: AppColors.error,
              onPressed: () => _showDeleteDialog(context, ref),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Goal', style: AppTextStyles.headingMedium),
        content: Text(
          'Are you sure you want to delete "${saving.name}"? This action cannot be undone.',
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
              await ref.read(savingRepositoryProvider).deleteSaving(saving.id);
              ref.invalidate(savingsProvider);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to saving list
              }
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountInfo extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _AmountInfo({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(value, style: AppTextStyles.labelMedium),
      ],
    );
  }
}
