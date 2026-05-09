import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../home/providers/home_provider.dart';

// Provider untuk filter periode
enum ReportPeriod { last7Days, last30Days, last3Months, last6Months }

final reportPeriodProvider = StateProvider<ReportPeriod>(
  (ref) => ReportPeriod.last30Days,
);

final reportTabProvider = StateProvider<int>((ref) => 0); // 0=income, 1=expense

// Provider transaksi terfilter berdasarkan periode
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final period = ref.watch(reportPeriodProvider);
  final transactions = ref.watch(transactionsProvider);

  return transactions.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      DateTime start;
      switch (period) {
        case ReportPeriod.last7Days:
          start = now.subtract(const Duration(days: 7));
          break;
        case ReportPeriod.last30Days:
          start = now.subtract(const Duration(days: 30));
          break;
        case ReportPeriod.last3Months:
          start = now.subtract(const Duration(days: 90));
          break;
        case ReportPeriod.last6Months:
          start = now.subtract(const Duration(days: 180));
          break;
      }
      return list.where((t) => t.date.isAfter(start)).toList();
    },
    orElse: () => [],
  );
});

// Provider total income & expense terfilter
final filteredIncomeProvider = Provider<double>((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  return list
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final filteredExpenseProvider = Provider<double>((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  return list
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

// Provider expense per kategori (mock category names)
final expenseByCategoryProvider = Provider<Map<String, double>>((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  final expenses = list.where((t) => t.type == TransactionType.expense);

  final Map<String, double> result = {};
  for (final t in expenses) {
    // Map categoryId ke nama (mock)
    final name = _getCategoryName(t.categoryId);
    result[name] = (result[name] ?? 0) + t.amount;
  }
  return result;
});

final incomeByCategoryProvider = Provider<Map<String, double>>((ref) {
  final list = ref.watch(filteredTransactionsProvider);
  final incomes = list.where((t) => t.type == TransactionType.income);

  final Map<String, double> result = {};
  for (final t in incomes) {
    final name = _getCategoryName(t.categoryId);
    result[name] = (result[name] ?? 0) + t.amount;
  }
  return result;
});

String _getCategoryName(String categoryId) {
  const map = {
    'cat-001': 'Food & Beverage',
    'cat-002': 'Transportation',
    'cat-003': 'Education',
    'cat-004': 'Shopping',
    'cat-005': 'Health',
    'cat-006': 'Entertainment',
    'cat-income-001': 'Salary',
    'cat-income-002': 'Business',
    'cat-income-003': 'Freelance',
    'cat-income-004': 'Investment',
    'cat-income-005': 'Bonus',
    'cat-transfer-001': 'Bank',
    'cat-transfer-002': 'E-Wallet',
    'cat-transfer-003': 'Cash',
  };
  return map[categoryId] ?? 'Others';
}

// Warna untuk chart segments
const _chartColors = [
  Color(0xFF2D5A3D),
  Color(0xFF4CAF50),
  Color(0xFFFF5722),
  Color(0xFF2196F3),
  Color(0xFFFFC107),
  Color(0xFF9C27B0),
  Color(0xFF00BCD4),
  Color(0xFFFF9800),
];

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final tab = ref.watch(reportTabProvider);
    final filteredIncome = ref.watch(filteredIncomeProvider);
    final filteredExpense = ref.watch(filteredExpenseProvider);
    final expenseByCategory = ref.watch(expenseByCategoryProvider);
    final incomeByCategory = ref.watch(incomeByCategoryProvider);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final isIncome = tab == 0;
    final totalAmount = isIncome ? filteredIncome : filteredExpense;
    final categoryData = isIncome ? incomeByCategory : expenseByCategory;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Report', style: AppTextStyles.headingLarge),
                // Export button
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Export',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Period filter dropdown
            _PeriodDropdown(
              selected: period,
              onChanged: (p) =>
                  ref.read(reportPeriodProvider.notifier).state = p,
            ),

            const SizedBox(height: 20),

            // Income / Expense tab
            Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Income',
                    isSelected: isIncome,
                    onTap: () => ref.read(reportTabProvider.notifier).state = 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    label: 'Expense',
                    isSelected: !isIncome,
                    onTap: () => ref.read(reportTabProvider.notifier).state = 1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Donut chart
            if (categoryData.isEmpty)
              _buildEmptyChart(context, isIncome)
            else
              _buildDonutChart(
                totalAmount: totalAmount,
                categoryData: categoryData,
                currencyFormat: currencyFormat,
                isIncome: isIncome,
              ),

            const SizedBox(height: 28),

            // Cash Flow Profile bar chart
            Text('Cash Flow Profile', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),

            _buildBarChart(filteredTransactions),

            const SizedBox(height: 28),

            // Expense by category breakdown
            if (categoryData.isNotEmpty) ...[
              Text(
                '${isIncome ? 'Income' : 'Expenses'} by Category',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 12),
              _buildCategoryBreakdown(
                categoryData: categoryData,
                total: totalAmount,
                currencyFormat: currencyFormat,
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, bool isIncome) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pie_chart_outline, size: 56, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(
            'No ${isIncome ? 'income' : 'expense'} data\nfor this period',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart({
    required double totalAmount,
    required Map<String, double> categoryData,
    required NumberFormat currencyFormat,
    required bool isIncome,
  }) {
    final sections = categoryData.entries.toList();

    return Row(
      children: [
        // Donut chart
        SizedBox(
          width: 180,
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 55,
              sections: sections.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final percentage = totalAmount > 0
                    ? (item.value / totalAmount * 100)
                    : 0.0;
                return PieChartSectionData(
                  value: item.value,
                  color: _chartColors[index % _chartColors.length],
                  radius: 40,
                  title: '${percentage.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Center info + legend
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total\n${isIncome ? 'Income' : 'Expense'}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormat.format(totalAmount),
                style: AppTextStyles.labelLarge.copyWith(
                  color: isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              ...sections.asMap().entries.take(5).map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _chartColors[index % _chartColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.key,
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<TransactionModel> transactions) {
    // Group by week - ambil 6 minggu terakhir
    final now = DateTime.now();
    final weeks = List.generate(6, (i) {
      final weekStart = now.subtract(
        Duration(days: (5 - i) * 7 + now.weekday - 1),
      );
      return weekStart;
    });

    double maxY = 0;
    final incomeData = <double>[];
    final expenseData = <double>[];

    for (final weekStart in weeks) {
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekTransactions = transactions.where(
        (t) => t.date.isAfter(weekStart) && t.date.isBefore(weekEnd),
      );

      final income = weekTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = weekTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      incomeData.add(income);
      expenseData.add(expense);

      if (income > maxY) maxY = income;
      if (expense > maxY) maxY = expense;
    }

    if (maxY == 0) maxY = 1000000;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  final formatted = value >= 1000000
                      ? '${(value / 1000000).toStringAsFixed(1)}M'
                      : value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}K'
                      : value.toStringAsFixed(0);
                  return Text(
                    formatted,
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeks.length) {
                    return const SizedBox();
                  }
                  return Text(
                    'W${index + 1}',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: AppColors.divider, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: incomeData[index],
                  color: AppColors.income,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: expenseData[index],
                  color: AppColors.expense,
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown({
    required Map<String, double> categoryData,
    required double total,
    required NumberFormat currencyFormat,
  }) {
    final sorted = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final percentage = total > 0 ? (item.value / total * 100) : 0.0;
        final color = _chartColors[index % _chartColors.length];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.key, style: AppTextStyles.labelMedium),
                  ),
                  Text(
                    currencyFormat.format(item.value),
                    style: AppTextStyles.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? item.value / total : 0,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Period dropdown widget
class _PeriodDropdown extends StatelessWidget {
  final ReportPeriod selected;
  final void Function(ReportPeriod) onChanged;

  const _PeriodDropdown({required this.selected, required this.onChanged});

  String _label(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.last7Days:
        return 'Last 7 Days';
      case ReportPeriod.last30Days:
        return 'Last 30 Days';
      case ReportPeriod.last3Months:
        return 'Last 3 Months';
      case ReportPeriod.last6Months:
        return 'Last 6 Months';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                Text('Select Period', style: AppTextStyles.headingMedium),
                const SizedBox(height: 16),
                ...ReportPeriod.values.map(
                  (p) => GestureDetector(
                    onTap: () {
                      onChanged(p);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _label(p),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: p == selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: p == selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (p == selected)
                            Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_label(selected), style: AppTextStyles.labelMedium),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
