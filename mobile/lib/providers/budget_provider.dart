// lib/providers/budget_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/budget_model.dart';
import '../data/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(apiClient: ref.watch(apiClientProvider));
});

class BudgetState {
  final List<BudgetModel> budgets;
  final bool isLoading;
  final String? errorMessage;

  const BudgetState({
    this.budgets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class BudgetNotifier extends StateNotifier<BudgetState> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super(const BudgetState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getBudgets();
    result.when(
      success: (budgets) => state = BudgetState(budgets: budgets),
      error: (f) =>
          state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createBudget(data);
    return result.when(
      success: (budget) {
        state = state.copyWith(
          isLoading: false,
          budgets: [...state.budgets, budget],
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.updateBudget(id, data);
    return result.when(
      success: (updated) {
        state = state.copyWith(
          isLoading: false,
          budgets: state.budgets.map((b) => b.id == id ? updated : b).toList(),
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.deleteBudget(id);
    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          budgets: state.budgets.where((b) => b.id != id).toList(),
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

final budgetProvider = StateNotifierProvider<BudgetNotifier, BudgetState>((
  ref,
) {
  return BudgetNotifier(ref.watch(budgetRepositoryProvider));
});
