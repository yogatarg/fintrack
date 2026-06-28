import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  /// Override saat build/run:
  ///
  /// Android Device:
  /// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
  ///
  /// Windows:
  /// flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
  ///
  /// Production:
  /// flutter build apk --dart-define=API_BASE_URL=https://api.fintrack.com/api
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    // Android Emulator
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    // Windows Desktop / Chrome localhost
    return 'http://127.0.0.1:8000/api';
  }

  // =========================
  // AUTH
  // =========================

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';

  // =========================
  // DASHBOARD
  // =========================

  static const String dashboard = '/dashboard';

  // =========================
  // WALLET
  // =========================

  static const String wallets = '/wallets';

  // =========================
  // CATEGORY
  // =========================

  static const String categories = '/categories';

  // =========================
  // TRANSACTION
  // =========================

  static const String transactions = '/transactions';

  // =========================
  // BUDGET
  // =========================

  static const String budgets = '/budgets';

  // =========================
  // SAVING GOAL
  // =========================

  static const String savingGoals = '/saving-goals';

  // =========================
  // ANALYTICS
  // =========================

  static const String spendingAlert = '/analytics/spending-alert';

  static const String budgetRisk = '/analytics/budget-risk';

  static const String spendingPrediction = '/analytics/spending-prediction';

  static const String savingRecommendation = '/analytics/saving-recommendation';

  static const String financialHealth = '/analytics/financial-health';

  static const String anomalyDetection = '/analytics/anomaly-detection';

  static const String monthlyReview = '/analytics/monthly-review';

  static const String noSpendDay = '/analytics/no-spend-day';

  // =========================
  // NETWORK
  // =========================

  static const int connectTimeout = 10000;
  static const int receiveTimeout = 10000;
}
