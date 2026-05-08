import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/wallet_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';

// Mock categories
final _expenseCategories = [
  CategoryModel(
    id: 'cat-001',
    name: 'Food & Beverage',
    type: CategoryType.expense,
  ),
  CategoryModel(
    id: 'cat-002',
    name: 'Transportation',
    type: CategoryType.expense,
  ),
  CategoryModel(id: 'cat-003', name: 'Education', type: CategoryType.expense),
  CategoryModel(id: 'cat-004', name: 'Shopping', type: CategoryType.expense),
  CategoryModel(id: 'cat-005', name: 'Health', type: CategoryType.expense),
  CategoryModel(
    id: 'cat-006',
    name: 'Entertainment',
    type: CategoryType.expense,
  ),
];

final _incomeCategories = [
  CategoryModel(
    id: 'cat-income-001',
    name: 'Salary',
    type: CategoryType.income,
  ),
  CategoryModel(
    id: 'cat-income-002',
    name: 'Business',
    type: CategoryType.income,
  ),
  CategoryModel(
    id: 'cat-income-003',
    name: 'Freelance',
    type: CategoryType.income,
  ),
  CategoryModel(
    id: 'cat-income-004',
    name: 'Investment',
    type: CategoryType.income,
  ),
  CategoryModel(id: 'cat-income-005', name: 'Bonus', type: CategoryType.income),
];

final _transferCategories = [
  CategoryModel(
    id: 'cat-transfer-001',
    name: 'Bank',
    type: CategoryType.transfer,
  ),
  CategoryModel(
    id: 'cat-transfer-002',
    name: 'E-Wallet',
    type: CategoryType.transfer,
  ),
  CategoryModel(
    id: 'cat-transfer-003',
    name: 'Cash',
    type: CategoryType.transfer,
  ),
];

class CreateTransactionScreen extends ConsumerStatefulWidget {
  final String type;

  const CreateTransactionScreen({super.key, required this.type});

  @override
  ConsumerState<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState
    extends ConsumerState<CreateTransactionScreen> {
  final _nominalController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryModel? _selectedCategory;
  WalletModel? _selectedWallet;
  WalletModel? _selectedToWallet;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  List<CategoryModel> get _categories {
    switch (widget.type) {
      case 'income':
        return _incomeCategories;
      case 'transfer':
        return _transferCategories;
      default:
        return _expenseCategories;
    }
  }

  TransactionType get _transactionType {
    switch (widget.type) {
      case 'income':
        return TransactionType.income;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }

  Color get _typeColor {
    switch (widget.type) {
      case 'income':
        return AppColors.income;
      case 'transfer':
        return AppColors.transfer;
      default:
        return AppColors.expense;
    }
  }

  String get _title {
    return '${widget.type[0].toUpperCase()}${widget.type.substring(1)}';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleCreate() async {
    if (_nominalController.text.isEmpty) {
      _showError('Please enter nominal amount');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }
    if (_selectedWallet == null) {
      _showError('Please select a wallet');
      return;
    }
    if (widget.type == 'transfer' && _selectedToWallet == null) {
      _showError('Please select destination wallet');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).user!;
      final rawAmount = _nominalController.text.replaceAll('.', '');
      final amount = double.parse(rawAmount);

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: user.id,
        walletId: _selectedWallet!.id,
        toWalletId: _selectedToWallet?.id,
        categoryId: _selectedCategory!.id,
        type: _transactionType,
        amount: amount,
        description: _descriptionController.text.isEmpty
            ? _selectedCategory!.name
            : _descriptionController.text,
        date: _selectedDate,
      );

      await ref.read(transactionRepositoryProvider).addTransaction(transaction);

      // Invalidate providers biar data refresh
      ref.invalidate(transactionsProvider);
      ref.invalidate(walletsProvider);

      if (mounted) {
        Navigator.pop(context);
        _showSuccess();
      }
    } catch (e) {
      _showError('Failed to create transaction');
    } finally {
      setState(() => _isLoading = false);
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

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction created successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider);

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
        title: Text('Create Transaction', style: AppTextStyles.headingMedium),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Nominal input
            Text('Nominal', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.primary)),
              ),
              child: Row(
                children: [
                  Text(
                    'Rp',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.amountMedium,
                      decoration: InputDecoration(
                        hintText: 'Add Nominal',
                        hintStyle: AppTextStyles.amountMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        // Format angka dengan titik
                        final clean = value.replaceAll('.', '');
                        if (clean.isEmpty) return;
                        final formatted = NumberFormat(
                          '#,###',
                          'id_ID',
                        ).format(int.tryParse(clean) ?? 0);
                        _nominalController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(
                            offset: formatted.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Category
            Text('Category', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _DropdownField(
              hint: 'Choose Category',
              value: _selectedCategory?.name,
              onTap: () => _showCategoryPicker(),
            ),

            const SizedBox(height: 20),

            // Wallet (berbeda untuk transfer)
            if (widget.type == 'transfer') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From Wallet', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        _DropdownField(
                          hint: 'Choose Wallet',
                          value: _selectedWallet?.name,
                          onTap: () => _showWalletPicker(isFrom: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To Wallet', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        _DropdownField(
                          hint: 'Choose Wallet',
                          value: _selectedToWallet?.name,
                          onTap: () => _showWalletPicker(isFrom: false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text('Wallet', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              _DropdownField(
                hint: 'Choose Wallet',
                value: _selectedWallet?.name,
                onTap: () => _showWalletPicker(isFrom: true),
              ),
            ],

            const SizedBox(height: 20),

            // Date
            Text('Date', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.primary)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      style: AppTextStyles.bodyLarge,
                    ),
                    Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            Text('Description', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.primary)),
              ),
              child: TextField(
                controller: _descriptionController,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Add Description',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Upload & Scan bill (hanya untuk expense)
            if (widget.type == 'expense') ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.upload_rounded,
                        color: AppColors.textSecondary,
                      ),
                      label: Text(
                        'Upload Bill',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.document_scanner_rounded,
                        color: AppColors.textSecondary,
                      ),
                      label: Text(
                        'Scan Bill',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            AppButton(
              label: 'Create',
              isLoading: _isLoading,
              onPressed: _handleCreate,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerModal(
        title: 'Choose Category',
        items: _categories.map((c) => c.name).toList(),
        onSelected: (index) {
          setState(() => _selectedCategory = _categories[index]);
        },
      ),
    );
  }

  void _showWalletPicker({required bool isFrom}) {
    final wallets = ref.read(walletsProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerModal(
        title: isFrom ? 'From Wallet' : 'To Wallet',
        items: wallets.map((w) => w.name).toList(),
        onSelected: (index) {
          setState(() {
            if (isFrom) {
              _selectedWallet = wallets[index];
            } else {
              _selectedToWallet = wallets[index];
            }
          });
        },
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;

  const _DropdownField({required this.hint, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.primary)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? hint,
              style: AppTextStyles.bodyLarge.copyWith(
                color: value != null
                    ? AppColors.textPrimary
                    : AppColors.textHint,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _PickerModal extends StatelessWidget {
  final String title;
  final List<String> items;
  final void Function(int index) onSelected;

  const _PickerModal({
    required this.title,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(title, style: AppTextStyles.headingMedium),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.asMap().entries.map(
            (entry) => GestureDetector(
              onTap: () {
                onSelected(entry.key);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.divider)),
                ),
                child: Text(entry.value, style: AppTextStyles.bodyLarge),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
