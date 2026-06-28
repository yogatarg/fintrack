// lib/data/repositories/transaction_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Result<TransactionPageModel>> getTransactions({
    int page = 1,
    String? type,
    int? walletId,
    int? categoryId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.transactions,
        queryParameters: {
          'page': page,
          if (type != null) 'type': type,
          if (walletId != null) 'wallet_id': walletId,
          if (categoryId != null) 'category_id': categoryId,
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      final items = (response.data['data'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
      final meta = response.data['meta'];

      return Success(
        TransactionPageModel(
          items: items,
          currentPage: meta['current_page'] as int,
          lastPage: meta['last_page'] as int,
          total: meta['total'] as int,
        ),
      );
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<TransactionModel>> createTransaction(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.transactions,
        data: data,
      );
      return Success(TransactionModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<TransactionModel>> updateTransaction(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.transactions}/$id',
        data: data,
      );
      return Success(TransactionModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<void>> deleteTransaction(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.transactions}/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}