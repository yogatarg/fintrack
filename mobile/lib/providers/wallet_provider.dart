// lib/providers/wallet_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/wallet_model.dart';
import '../data/repositories/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(apiClient: ref.watch(apiClientProvider));
});

class WalletState {
  final List<WalletModel> wallets;
  final bool isLoading;
  final String? errorMessage;

  const WalletState({
    this.wallets = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  WalletState copyWith({
    List<WalletModel>? wallets,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WalletState(
      wallets: wallets ?? this.wallets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  double get totalBalance =>
      wallets.fold(0, (sum, w) => sum + w.balance);
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(const WalletState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _repository.getWallets();
    result.when(
      success: (wallets) => state = WalletState(wallets: wallets),
      error: (f) => state = state.copyWith(
        isLoading: false,
        errorMessage: f.message,
      ),
    );
  }

  Future<bool> create(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createWallet(data);
    return result.when(
      success: (wallet) {
        state = state.copyWith(
          isLoading: false,
          wallets: [...state.wallets, wallet],
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
    final result = await _repository.updateWallet(id, data);
    return result.when(
      success: (updated) {
        state = state.copyWith(
          isLoading: false,
          wallets: state.wallets
              .map((w) => w.id == id ? updated : w)
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
    final result = await _repository.deleteWallet(id);
    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          wallets: state.wallets.where((w) => w.id != id).toList(),
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

final walletProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.watch(walletRepositoryProvider));
});