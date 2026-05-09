import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type);
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
}
