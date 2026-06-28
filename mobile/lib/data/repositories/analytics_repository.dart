// lib/data/repositories/analytics_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/analytics_model.dart';

class AnalyticsRepository {
  final ApiClient _apiClient;

  AnalyticsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Result<SpendingAlertModel>> getSpendingAlert() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.spendingAlert);
      return Success(SpendingAlertModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<List<BudgetRiskModel>>> getBudgetRisk() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.budgetRisk);
      final list = (response.data['data'] as List)
          .map((e) => BudgetRiskModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<SpendingPredictionModel>> getSpendingPrediction() async {
    try {
      final response =
          await _apiClient.dio.get(ApiConstants.spendingPrediction);
      return Success(
        SpendingPredictionModel.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<List<SavingRecommendationModel>>>
      getSavingRecommendation() async {
    try {
      final response =
          await _apiClient.dio.get(ApiConstants.savingRecommendation);
      final list = (response.data['data'] as List)
          .map((e) => SavingRecommendationModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<FinancialHealthModel>> getFinancialHealth() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.financialHealth);
      return Success(FinancialHealthModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<List<AnomalyModel>>> getAnomalyDetection() async {
    try {
      final response =
          await _apiClient.dio.get(ApiConstants.anomalyDetection);
      final list = (response.data['data'] as List)
          .map((e) => AnomalyModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<MonthlyReviewModel>> getMonthlyReview({String? month}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.monthlyReview,
        queryParameters: month != null ? {'month': month} : null,
      );
      return Success(MonthlyReviewModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<NoSpendDayModel>> getNoSpendDay() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.noSpendDay);
      return Success(NoSpendDayModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}