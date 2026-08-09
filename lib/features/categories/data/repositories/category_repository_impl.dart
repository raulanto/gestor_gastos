import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<Category>> getCategories() async {
    return await _localDataSource.getCategories();
  }

  @override
  Future<Category> createCategory(Category category) async {
    return await _localDataSource.createCategory(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    return await _localDataSource.updateCategory(category);
  }

  @override
  Future<void> deleteCategory(int id) async {
    return await _localDataSource.deleteCategory(id);
  }
}
