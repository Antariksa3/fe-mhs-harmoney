import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../home/providers/home_provider.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionType? _filterType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
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

                // Cash flow card
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
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
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
                      color: _filterType != null
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _filterType != null
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          color: _filterType != null
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _filterType != null
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
            child: transactions.when(
              data: (list) {
                // Apply filter
                var filtered = list.where((t) {
                  final matchSearch =
                      _searchQuery.isEmpty ||
                      (t.description?.toLowerCase() ?? '').contains(
                        _searchQuery.toLowerCase(),
                      );
                  final matchFilter =
                      _filterType == null || t.type == _filterType;
                  return matchSearch && matchFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
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
                  );
                }

                // Group by date
                final grouped = <String, List<TransactionModel>>{};
                for (final t in filtered) {
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
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
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
                  isSelected: _filterType == null,
                  onTap: () {
                    setState(() => _filterType = null);
                    Navigator.pop(context);
                  },
                ),
                _FilterChip(
                  label: 'Expense',
                  isSelected: _filterType == TransactionType.expense,
                  color: AppColors.expense,
                  onTap: () {
                    setState(() => _filterType = TransactionType.expense);
                    Navigator.pop(context);
                  },
                ),
                _FilterChip(
                  label: 'Income',
                  isSelected: _filterType == TransactionType.income,
                  color: AppColors.income,
                  onTap: () {
                    setState(() => _filterType = TransactionType.income);
                    Navigator.pop(context);
                  },
                ),
                _FilterChip(
                  label: 'Transfer',
                  isSelected: _filterType == TransactionType.transfer,
                  color: AppColors.transfer,
                  onTap: () {
                    setState(() => _filterType = TransactionType.transfer);
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
    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;

    final color = isExpense
        ? AppColors.expense
        : isIncome
        ? AppColors.income
        : AppColors.transfer;

    final prefix = isExpense
        ? '- '
        : isIncome
        ? '+ '
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpense
                  ? Icons.arrow_upward_rounded
                  : isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_forward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              transaction.description ?? 'Transaction',
              style: AppTextStyles.labelMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix${currencyFormat.format(transaction.amount)}',
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
              const SizedBox(height: 2),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
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
