// lib/data/repositories/auth_repository.dart

import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../../core/utils/result.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Future<Result<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data['data'];
      await _tokenStorage.saveToken(data['token'] as String);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      return Success(user);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'];
      await _tokenStorage.saveToken(data['token'] as String);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      return Success(user);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _apiClient.dio.post(ApiConstants.logout);
      await _tokenStorage.deleteToken();
      return const Success(null);
    } on DioException catch (e) {
      // Tetap hapus token lokal meski server error
      await _tokenStorage.deleteToken();
      return Error(_apiClient.handleError(e));
    }
  }

  Future<Result<UserModel>> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);
      final user = UserModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      return Success(user);
    } on DioException catch (e) {
      return Error(_apiClient.handleError(e));
    }
  }

  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasToken();
  }
}