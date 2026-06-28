// lib/data/repositories/category_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/result.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiClient _apiClient;

  CategoryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Result<List<CategoryModel>>> getCategories({String? type}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.categories,
        queryParameters: type != null ? {'type': type} : null,
      );
      final list = (response.data['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<CategoryModel>> createCategory(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.categories,
        data: data,
      );
      return Success(
        CategoryModel.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<CategoryModel>> updateCategory(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.categories}/$id',
        data: data,
      );
      return Success(
        CategoryModel.fromJson(response.data['data']),
      );
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<void>> deleteCategory(int id) async {
    try {
      await _apiClient.dio.delete('${ApiConstants.categories}/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }
}