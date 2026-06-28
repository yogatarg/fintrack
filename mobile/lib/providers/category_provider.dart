// lib/providers/category_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(apiClient: ref.watch(apiClientProvider));
});

class CategoryState {
  final List<CategoryModel> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<CategoryModel> get incomeCategories =>
      categories.where((c) => c.type == 'income').toList();

  List<CategoryModel> get expenseCategories =>
      categories.where((c) => c.type == 'expense').toList();
}

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const CategoryState()) {
    fetch();
  }

  Future<void> fetch({String? type}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getCategories(type: type);
    result.when(
      success: (categories) => state = CategoryState(categories: categories),
      error: (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
      ),
    );
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createCategory(data);
    return result.when(
      success: (category) {
        state = state.copyWith(
          isLoading: false,
          categories: [...state.categories, category],
        );
        return true;
      },
      error: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateCategory(id, data);
    return result.when(
      success: (updated) {
        state = state.copyWith(
          isLoading: false,
          categories: state.categories
              .map((c) => c.id == id ? updated : c)
              .toList(),
        );
        return true;
      },
      error: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> delete(int id) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.deleteCategory(id);
    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          categories: state.categories.where((c) => c.id != id).toList(),
        );
        return true;
      },
      error: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(ref.watch(categoryRepositoryProvider));
});