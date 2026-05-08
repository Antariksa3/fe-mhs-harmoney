import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/category_model.dart';

// Provider untuk categories
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<CategoryModel>>((ref) {
      return CategoriesNotifier();
    });

class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  CategoriesNotifier()
    : super([
        // Expense
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
        CategoryModel(
          id: 'cat-003',
          name: 'Education',
          type: CategoryType.expense,
        ),
        CategoryModel(
          id: 'cat-004',
          name: 'Shopping',
          type: CategoryType.expense,
        ),
        CategoryModel(
          id: 'cat-005',
          name: 'Health',
          type: CategoryType.expense,
        ),
        CategoryModel(
          id: 'cat-006',
          name: 'Entertainment',
          type: CategoryType.expense,
        ),
        CategoryModel(
          id: 'cat-007',
          name: 'Technology',
          type: CategoryType.expense,
        ),
        // Income
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
        CategoryModel(
          id: 'cat-income-005',
          name: 'Bonus',
          type: CategoryType.income,
        ),
        // Transfer
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
        CategoryModel(
          id: 'cat-transfer-004',
          name: 'Others',
          type: CategoryType.transfer,
        ),
      ]);

  List<CategoryModel> getByType(CategoryType type) =>
      state.where((c) => c.type == type).toList();

  void addCategory(CategoryModel category) {
    state = [...state, category];
  }

  void updateCategory(CategoryModel updated) {
    state = state.map((c) => c.id == updated.id ? updated : c).toList();
  }

  void deleteCategory(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}

class ManageCategoryScreen extends ConsumerStatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  ConsumerState<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends ConsumerState<ManageCategoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    final expenseCategories = categories
        .where((c) => c.type == CategoryType.expense)
        .toList();
    final incomeCategories = categories
        .where((c) => c.type == CategoryType.income)
        .toList();
    final transferCategories = categories
        .where((c) => c.type == CategoryType.transfer)
        .toList();

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
        title: Text('Manage Category', style: AppTextStyles.headingMedium),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.labelMedium,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
            Tab(text: 'Transfer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(
            categories: expenseCategories,
            type: CategoryType.expense,
            addLabel: 'Add Expense Category',
          ),
          _CategoryList(
            categories: incomeCategories,
            type: CategoryType.income,
            addLabel: 'Add Income Category',
          ),
          _CategoryList(
            categories: transferCategories,
            type: CategoryType.transfer,
            addLabel: 'Add Transfer Category',
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final List<CategoryModel> categories;
  final CategoryType type;
  final String addLabel;

  const _CategoryList({
    required this.categories,
    required this.type,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _showEditModal(context, ref, cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.label_outline,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: AppTextStyles.labelMedium,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Add button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _showAddModal(context, ref),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: Text(
                addLabel,
                style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormModal(
        title: 'Add Category',
        buttonLabel: 'Add',
        onSubmit: (name, subcategory) {
          final newCat = CategoryModel(
            id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            type: type,
            subcategories: subcategory.isNotEmpty ? [subcategory] : [],
          );
          ref.read(categoriesProvider.notifier).addCategory(newCat);
        },
      ),
    );
  }

  void _showEditModal(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoryFormModal(
        title: 'Edit Category',
        buttonLabel: 'Save',
        initialName: category.name,
        initialSubcategory: category.subcategories.isNotEmpty
            ? category.subcategories.first
            : '',
        showDelete: true,
        onSubmit: (name, subcategory) {
          final updated = CategoryModel(
            id: category.id,
            name: name,
            type: category.type,
            subcategories: subcategory.isNotEmpty ? [subcategory] : [],
          );
          ref.read(categoriesProvider.notifier).updateCategory(updated);
        },
        onDelete: () {
          ref.read(categoriesProvider.notifier).deleteCategory(category.id);
        },
      ),
    );
  }
}

class _CategoryFormModal extends StatefulWidget {
  final String title;
  final String buttonLabel;
  final String? initialName;
  final String? initialSubcategory;
  final bool showDelete;
  final void Function(String name, String subcategory) onSubmit;
  final VoidCallback? onDelete;

  const _CategoryFormModal({
    required this.title,
    required this.buttonLabel,
    this.initialName,
    this.initialSubcategory,
    this.showDelete = false,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<_CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<_CategoryFormModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _subcategoryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _subcategoryController = TextEditingController(
      text: widget.initialSubcategory ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Category name is required'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    widget.onSubmit(
      _nameController.text.trim(),
      _subcategoryController.text.trim(),
    );
    Navigator.pop(context);
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: AppTextStyles.headingMedium),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.label_outline,
                color: AppColors.primary,
                size: 30,
              ),
            ),

            const SizedBox(height: 20),

            // Category Name
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Category Name', style: AppTextStyles.labelLarge),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 20,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Add Category Name',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                counterStyle: AppTextStyles.bodySmall,
              ),
            ),

            const SizedBox(height: 16),

            // Subcategory (optional)
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text('Subcategory', style: AppTextStyles.labelLarge),
                  const SizedBox(width: 6),
                  Text(
                    '(optional)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subcategoryController,
              maxLength: 20,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Add Subcategory',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textHint,
                ),
                suffixIcon: Icon(Icons.add, color: AppColors.primary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                counterStyle: AppTextStyles.bodySmall,
              ),
            ),

            const SizedBox(height: 24),

            // Delete (hanya saat edit)
            if (widget.showDelete) ...[
              GestureDetector(
                onTap: () {
                  widget.onDelete?.call();
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete Category',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.buttonLabel,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
