// lib/data/repositories/budget_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final ApiClient _apiClient;

  BudgetRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Result<List<BudgetModel>>> getBudgets() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.budgets);
      final list = (response.data['data'] as List)
          .map((e) => BudgetModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<BudgetModel>> createBudget(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiClient.dio.post(ApiConstants.budgets, data: data);
      return Success(BudgetModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<BudgetModel>> updateBudget(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.budgets}/$id',
        data: data,
      );
      return Success(BudgetModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<void>> deleteBudget(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.budgets}/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}