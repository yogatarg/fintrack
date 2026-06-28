// lib/providers/transaction_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(apiClient: ref.watch(apiClientProvider));
});

class TransactionFilter {
  final String? type;
  final int? walletId;
  final int? categoryId;
  final String? startDate;
  final String? endDate;

  const TransactionFilter({
    this.type,
    this.walletId,
    this.categoryId,
    this.startDate,
    this.endDate,
  });

  bool get isEmpty =>
      type == null &&
      walletId == null &&
      categoryId == null &&
      startDate == null &&
      endDate == null;

  TransactionFilter copyWith({
    String? type,
    int? walletId,
    int? categoryId,
    String? startDate,
    String? endDate,
    bool clearType = false,
    bool clearWallet = false,
    bool clearCategory = false,
    bool clearDate = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      startDate: clearDate ? null : (startDate ?? this.startDate),
      endDate: clearDate ? null : (endDate ?? this.endDate),
    );
  }
}

class TransactionState {
  final List<TransactionModel> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final TransactionFilter filter;

  const TransactionState({
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.filter = const TransactionFilter(),
  });

  bool get hasMore => currentPage < lastPage;

  TransactionState copyWith({
    List<TransactionModel>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    TransactionFilter? filter,
  }) {
    return TransactionState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      filter: filter ?? this.filter,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super(const TransactionState()) {
    fetch();
  }

  Future<void> fetch({TransactionFilter? newFilter}) async {
    final filter = newFilter ?? state.filter;

    state = state.copyWith(isLoading: true, errorMessage: null, filter: filter);

    final result = await _repository.getTransactions(
      page: 1,
      type: filter.type,
      walletId: filter.walletId,
      categoryId: filter.categoryId,
      startDate: filter.startDate,
      endDate: filter.endDate,
    );

    result.when(
      success: (page) => state = TransactionState(
        items: page.items,
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        filter: filter,
      ),
      error: (f) =>
          state = state.copyWith(isLoading: false, errorMessage: f.message),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getTransactions(
      page: state.currentPage + 1,
      type: state.filter.type,
      walletId: state.filter.walletId,
      categoryId: state.filter.categoryId,
      startDate: state.filter.startDate,
      endDate: state.filter.endDate,
    );

    result.when(
      success: (page) => state = state.copyWith(
        items: [...state.items, ...page.items],
        currentPage: page.currentPage,
        lastPage: page.lastPage,
        isLoadingMore: false,
      ),
      error: (f) =>
          state = state.copyWith(isLoadingMore: false, errorMessage: f.message),
    );
  }

  Future<bool> create(Map<String, dynamic> data) async {
    final result = await _repository.createTransaction(data);
    return result.when(
      success: (_) {
        fetch(); // refresh list + dashboard akan ter-update juga
        return true;
      },
      error: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> update(int id, Map<String, dynamic> data) async {
    final result = await _repository.updateTransaction(id, data);
    return result.when(
      success: (_) {
        fetch();
        return true;
      },
      error: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }

  Future<bool> delete(int id) async {
    final result = await _repository.deleteTransaction(id);
    return result.when(
      success: (_) {
        state = state.copyWith(
          items: state.items.where((t) => t.id != id).toList(),
        );
        return true;
      },
      error: (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
    );
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      return TransactionNotifier(ref.watch(transactionRepositoryProvider));
    });
