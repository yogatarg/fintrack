// lib/data/repositories/dashboard_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Result<DashboardModel>> getDashboard() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboard);
      final model = DashboardModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      return Success(model);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}