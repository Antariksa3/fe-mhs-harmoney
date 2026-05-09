import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/saving_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../home/providers/home_provider.dart';
import 'create_saving_screen.dart';
import 'saving_detail_screen.dart';

class SavingScreen extends ConsumerWidget {
  const SavingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savings = ref.watch(savingsProvider);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('Saving', style: AppTextStyles.headingLarge),
          const SizedBox(height: 20),

          Expanded(
            child: savings.when(
              data: (list) => list.isEmpty
                  ? _buildEmpty(context)
                  : _buildList(context, list),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),

          // Create Goals button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: AppButton(
              label: 'Create Goals →',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateSavingScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.savings_outlined, size: 72, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No saving goals yet',
            style: AppTextStyles.headingMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first saving goal\nto start tracking your progress',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<SavingModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _SavingCard(
            saving: list[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavingDetailScreen(saving: list[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SavingCard extends StatelessWidget {
  final SavingModel saving;
  final VoidCallback onTap;

  const _SavingCard({required this.saving, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final progress = saving.progressPercentage / 100;
    final daysLeft = saving.daysLeft;
    final isOverdue = daysLeft < 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.savings_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Name
                Expanded(
                  child: Text(
                    saving.name,
                    style: AppTextStyles.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Days left + percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverdue ? 'Overdue' : '$daysLeft Days Left',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOverdue
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${saving.progressPercentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.success : AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 8),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(saving.currentAmount),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  currencyFormat.format(saving.targetAmount),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
