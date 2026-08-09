import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryLocalDataSource(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(localDataSource);
});

final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<Category>>(() {
  return CategoriesNotifier();
});

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  late CategoryRepository _repository;

  @override
  FutureOr<List<Category>> build() async {
    _repository = ref.watch(categoryRepositoryProvider);
    return await _repository.getCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _repository.getCategories();
    });
  }

  Future<void> addCategory(Category category) async {
    await _repository.createCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}
