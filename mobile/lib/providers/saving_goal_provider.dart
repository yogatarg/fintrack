// lib/providers/saving_goal_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/saving_goal_model.dart';
import '../data/repositories/saving_goal_repository.dart';

final savingGoalRepositoryProvider = Provider<SavingGoalRepository>((ref) {
  return SavingGoalRepository(apiClient: ref.watch(apiClientProvider));
});

class SavingGoalState {
  final List<SavingGoalModel> goals;
  final bool isLoading;
  final String? errorMessage;

  const SavingGoalState({
    this.goals = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SavingGoalState copyWith({
    List<SavingGoalModel>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SavingGoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<SavingGoalModel> get activeGoals =>
      goals.where((g) => g.status == 'active').toList();

  List<SavingGoalModel> get completedGoals =>
      goals.where((g) => g.status == 'completed').toList();
}

class SavingGoalNotifier extends StateNotifier<SavingGoalState> {
  final SavingGoalRepository _repository;

  SavingGoalNotifier(this._repository) : super(const SavingGoalState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getGoals();
    result.when(
      success: (goals) => state = SavingGoalState(goals: goals),
      error: (f) =>
          state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.createGoal(data);
    return result.when(
      success: (goal) {
        state = state.copyWith(isLoading: false, goals: [...state.goals, goal]);
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
    final result = await _repository.updateGoal(id, data);
    return result.when(
      success: (updated) {
        state = state.copyWith(
          isLoading: false,
          goals: state.goals.map((g) => g.id == id ? updated : g).toList(),
        );
        return true;
      },
      error: (f) {
        state = state.copyWith(isLoading: false, errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> addProgress(int id, double amount) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.addProgress(id, amount);
    return result.when(
      success: (updated) {
        state = state.copyWith(
          isLoading: false,
          goals: state.goals.map((g) => g.id == id ? updated : g).toList(),
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
    final result = await _repository.deleteGoal(id);
    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          goals: state.goals.where((g) => g.id != id).toList(),
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

final savingGoalProvider =
    StateNotifierProvider<SavingGoalNotifier, SavingGoalState>((ref) {
      return SavingGoalNotifier(ref.watch(savingGoalRepositoryProvider));
    });
