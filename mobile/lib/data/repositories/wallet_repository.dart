// lib/data/repositories/wallet_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/wallet_model.dart';

class WalletRepository {
  final ApiClient _apiClient;

  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Result<List<WalletModel>>> getWallets() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.wallets);
      final list = (response.data['data'] as List)
          .map((e) => WalletModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<WalletModel>> createWallet(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.wallets,
        data: data,
      );
      return Success(
        WalletModel.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<WalletModel>> updateWallet(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.wallets}/$id',
        data: data,
      );
      return Success(
        WalletModel.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<void>> deleteWallet(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.wallets}/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}