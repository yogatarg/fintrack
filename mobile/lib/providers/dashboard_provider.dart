// lib/providers/dashboard_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(apiClient: ref.watch(apiClientProvider));
});

class DashboardState {
  final DashboardModel? data;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardModel? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;

  DashboardNotifier(this._repository) : super(const DashboardState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getDashboard();

    result.when(
      success: (data) => state = DashboardState(data: data),
      error: (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
    );
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});