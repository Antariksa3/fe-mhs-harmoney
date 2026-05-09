import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class MockCategoryRepository implements CategoryRepository {
  final List<CategoryModel> _categories = [
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
    CategoryModel(id: 'cat-003', name: 'Education', type: CategoryType.expense),
    CategoryModel(id: 'cat-004', name: 'Shopping', type: CategoryType.expense),
    CategoryModel(id: 'cat-005', name: 'Health', type: CategoryType.expense),
    CategoryModel(
      id: 'cat-006',
      name: 'Entertainment',
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
  ];

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_categories);
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories.where((c) => c.type == type).toList();
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: category.name,
      type: category.type,
    );
    _categories.add(newCategory);
    return newCategory;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories.removeWhere((c) => c.id == categoryId);
  }
}
