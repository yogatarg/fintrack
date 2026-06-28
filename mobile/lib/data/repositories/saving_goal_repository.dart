// lib/data/repositories/saving_goal_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/saving_goal_model.dart';

class SavingGoalRepository {
  final ApiClient _apiClient;

  SavingGoalRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Result<List<SavingGoalModel>>> getGoals({String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.savingGoals,
        queryParameters: status != null ? {'status': status} : null,
      );
      final list = (response.data['data'] as List)
          .map((e) => SavingGoalModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<SavingGoalModel>> createGoal(
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await _apiClient.dio.post(ApiConstants.savingGoals, data: data);
      return Success(SavingGoalModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<SavingGoalModel>> updateGoal(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.savingGoals}/$id',
        data: data,
      );
      return Success(SavingGoalModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<SavingGoalModel>> addProgress(
    int id,
    double amount,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.savingGoals}/$id/add-progress',
        data: {'amount': amount},
      );
      return Success(SavingGoalModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<void>> deleteGoal(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.savingGoals}/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}