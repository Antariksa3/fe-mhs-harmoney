import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/split_bill_model.dart';
import '../../../shared/widgets/app_button.dart';

class SplitBillResultScreen extends StatelessWidget {
  final SplitBillState state;

  const SplitBillResultScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'id_ID');
    final totals = state.totalsPerFriend;

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
        title: Text('Split Bill', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Per-person cards
            ...state.friends.map((friend) {
              final items = state.getItemsForFriend(friend.id);
              final total = totals[friend.id] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surface,
                ),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              friend.name[0].toUpperCase(),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            friend.name,
                            style: AppTextStyles.labelLarge,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total:', style: AppTextStyles.bodySmall),
                            Text(
                              'Rp${formatter.format(total.toInt())}',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Divider(color: AppColors.divider, height: 20),

                    // Item breakdown
                    if (items.isEmpty)
                      Text(
                        'Tidak ada item untuk orang ini.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      )
                    else
                      ...items.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text(
                                '${entry.key.quantity}x ${entry.key.name}',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const Spacer(),
                              Text(
                                'Rp${formatter.format(entry.value.toInt())}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            AppButton(
              label: 'Done',
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
