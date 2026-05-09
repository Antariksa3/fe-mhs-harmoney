import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../home/providers/home_provider.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil dari provider, bukan local state
    final filteredList = ref.watch(filteredTransactionListProvider);
    final isLoading = ref.watch(transactionLoadingProvider);
    final filterType = ref.watch(transactionFilterProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return SafeArea(
      child: Column(
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Text('Transaction', style: AppTextStyles.headingLarge),
                const SizedBox(height: 16),
                Text('Balance', style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(totalBalance),
                  style: AppTextStyles.amountLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CashFlowItem(
                          label: 'In',
                          amount: currencyFormat.format(totalIncome),
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.income,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppColors.divider),
                      Expanded(
                        child: _CashFlowItem(
                          label: 'Out',
                          amount: currencyFormat.format(totalExpense),
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search + Filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        // Update provider, bukan setState
                        ref.read(transactionSearchProvider.notifier).state =
                            value;
                      },
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search Transaction',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showFilterModal(context),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: filterType != null
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: filterType != null
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: filterType != null
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: filterType != null
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Transaction list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildGroupedList(filteredList, currencyFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(
    List<TransactionModel> list,
    NumberFormat currencyFormat,
  ) {
    // Group by date
    final grouped = <String, List<TransactionModel>>{};
    for (final t in list) {
      final key = DateFormat('MMMM dd, yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final dayTransactions = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                date,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...dayTransactions.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TransactionItem(
                  transaction: t,
                  currencyFormat: currencyFormat,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    final currentFilter = ref.read(transactionFilterProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Transaction Type', style: AppTextStyles.labelMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: currentFilter == null,
                  onTap: () {
                    ref.read(transactionFilterProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                ),
                _FilterChip(
                  label: 'Expense',
                  isSelected: currentFilter == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: () {
                    ref.read(transactionFilterProvider.notifier).state =
                        TransactionType.expense;
                    Navigator.pop(context);
                  },
                ),
                _FilterChip(
                  label: 'Income',
                  isSelected: currentFilter == TransactionType.income,
                  color: AppColors.income,
                  onTap: () {
                    ref.read(transactionFilterProvider.notifier).state =
                        TransactionType.income;
                    Navigator.pop(context);
                  },
                ),
                _FilterChip(
                  label: 'Transfer',
                  isSelected: currentFilter == TransactionType.transfer,
                  color: AppColors.transfer,
                  onTap: () {
                    ref.read(transactionFilterProvider.notifier).state =
                        TransactionType.transfer;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CashFlowItem extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _CashFlowItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.labelLarge.copyWith(color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final NumberFormat currencyFormat;

  const _TransactionItem({
    required this.transaction,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (transaction.type) {
      TransactionType.income => AppColors.income,
      TransactionType.transfer => AppColors.transfer,
      _ => AppColors.expense,
    };

    final icon = switch (transaction.type) {
      TransactionType.income => Icons.arrow_downward_rounded,
      TransactionType.transfer => Icons.swap_horiz_rounded,
      _ => Icons.arrow_upward_rounded,
    };

    final prefix = switch (transaction.type) {
      TransactionType.income => '+ ',
      TransactionType.transfer => '→ ',
      _ => '- ',
    };

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(transaction: transaction),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? 'Transaction',
                    style: AppTextStyles.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('HH:mm').format(transaction.date),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              '$prefix${currencyFormat.format(transaction.amount)}',
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? activeColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
