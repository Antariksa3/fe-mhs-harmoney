import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/saving_model.dart';
import '../../../core/models/wallet_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';

class CreateSavingScreen extends ConsumerStatefulWidget {
  final SavingModel? existingSaving; // null = create, not null = edit

  const CreateSavingScreen({super.key, this.existingSaving});

  @override
  ConsumerState<CreateSavingScreen> createState() => _CreateSavingScreenState();
}

class _CreateSavingScreenState extends ConsumerState<CreateSavingScreen> {
  final _nameController = TextEditingController();
  final _nominalController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  WalletModel? _selectedWallet;
  bool _isLoading = false;

  bool get _isEditing => widget.existingSaving != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.existingSaving!;
      _nameController.text = s.name;
      _nominalController.text = NumberFormat(
        '#,###',
        'id_ID',
      ).format(s.targetAmount.toInt());
      _startDate = s.startDate;
      _endDate = s.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = isStart ? DateTime(2020) : _startDate;
    final last = isStart
        ? _endDate
        : DateTime.now().add(const Duration(days: 365 * 5));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (_nameController.text.isEmpty) {
      _showError('Please enter target name');
      return;
    }
    if (_nominalController.text.isEmpty) {
      _showError('Please enter nominal target');
      return;
    }
    if (_selectedWallet == null && !_isEditing) {
      _showError('Please select wallet source');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).user!;
      final rawAmount = _nominalController.text
          .replaceAll('.', '')
          .replaceAll(',', '');
      final amount = double.parse(rawAmount);

      if (_isEditing) {
        final updated = SavingModel(
          id: widget.existingSaving!.id,
          userId: user.id,
          walletId: widget.existingSaving!.walletId,
          name: _nameController.text.trim(),
          targetAmount: amount,
          currentAmount: widget.existingSaving!.currentAmount,
          startDate: _startDate,
          endDate: _endDate,
        );
        await ref.read(savingRepositoryProvider).updateSaving(updated);
      } else {
        final saving = SavingModel(
          id: const Uuid().v4(),
          userId: user.id,
          walletId: _selectedWallet!.id,
          name: _nameController.text.trim(),
          targetAmount: amount,
          currentAmount: 0,
          startDate: _startDate,
          endDate: _endDate,
        );
        await ref.read(savingRepositoryProvider).addSaving(saving);
      }

      ref.invalidate(savingsProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Saving goal updated!' : 'Saving goal created!',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Something went wrong');
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
        title: Text(
          _isEditing ? 'Edit Saving' : 'Create Saving',
          style: AppTextStyles.headingMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Target Name
            Text('Target Name', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _UnderlineField(
              controller: _nameController,
              hint: 'Input Target Name',
            ),

            const SizedBox(height: 24),

            // Nominal Target
            Text('Nominal Target', style: AppTextStyles.labelLarge),
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
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Add Nominal',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textHint,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        final clean = value
                            .replaceAll('.', '')
                            .replaceAll(',', '');
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

            const SizedBox(height: 24),

            // Start Date
            Text('Start Date', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _DateField(
              date: _startDate,
              onTap: () => _selectDate(isStart: true),
            ),

            const SizedBox(height: 24),

            // End Date
            Text('End Date', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            _DateField(
              date: _endDate,
              onTap: () => _selectDate(isStart: false),
            ),

            // Wallet Source (hanya saat create)
            if (!_isEditing) ...[
              const SizedBox(height: 24),
              Text('Wallet Source', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              wallets.when(
                data: (list) => GestureDetector(
                  onTap: () => _showWalletPicker(list),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedWallet?.name ?? 'Choose Wallet',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: _selectedWallet != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),
            ],

            const SizedBox(height: 40),

            AppButton(
              label: _isEditing ? 'Save' : 'Create',
              isLoading: _isLoading,
              onPressed: _handleSave,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker(List<dynamic> wallets) {
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
                Text('Wallet Source', style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...wallets.map(
              (w) => GestureDetector(
                onTap: () {
                  setState(() => _selectedWallet = w);
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
                  child: Text(w.name, style: AppTextStyles.bodyLarge),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _UnderlineField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _UnderlineField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({required this.date, required this.onTap});

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
              DateFormat('MMMM dd, yyyy').format(date),
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
    );
  }
}
