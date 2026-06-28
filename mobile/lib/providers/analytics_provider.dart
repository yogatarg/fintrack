// lib/providers/analytics_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/network_providers.dart';
import '../core/utils/result.dart';
import '../data/models/analytics_model.dart';
import '../data/repositories/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(apiClient: ref.watch(apiClientProvider));
});

// Setiap fitur analytics independen — kalau satu gagal, yang lain tetap tampil
final spendingAlertProvider = FutureProvider.autoDispose<SpendingAlertModel>((
  ref,
) async {
  // Pertahankan data selama 5 menit sebelum dispose
  final link = ref.keepAlive();
  Future.delayed(const Duration(minutes: 5), () {
    link.close();
  });

  final repo = ref.watch(analyticsRepositoryProvider);
  final result = await repo.getSpendingAlert();
  return result.when(success: (data) => data, error: (f) => throw f);
});

final budgetRiskProvider = FutureProvider.autoDispose<List<BudgetRiskModel>>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final result = await repo.getBudgetRisk();
  return result.when(success: (data) => data, error: (f) => throw f);
});

final spendingPredictionProvider =
    FutureProvider.autoDispose<SpendingPredictionModel>((ref) async {
      final repo = ref.watch(analyticsRepositoryProvider);
      final result = await repo.getSpendingPrediction();
      return result.when(success: (data) => data, error: (f) => throw f);
    });

final savingRecommendationProvider =
    FutureProvider.autoDispose<List<SavingRecommendationModel>>((ref) async {
      final repo = ref.watch(analyticsRepositoryProvider);
      final result = await repo.getSavingRecommendation();
      return result.when(success: (data) => data, error: (f) => throw f);
    });

final financialHealthProvider =
    FutureProvider.autoDispose<FinancialHealthModel>((ref) async {
      final repo = ref.watch(analyticsRepositoryProvider);
      final result = await repo.getFinancialHealth();
      return result.when(success: (data) => data, error: (f) => throw f);
    });

final anomalyDetectionProvider = FutureProvider.autoDispose<List<AnomalyModel>>(
  (ref) async {
    final repo = ref.watch(analyticsRepositoryProvider);
    final result = await repo.getAnomalyDetection();
    return result.when(success: (data) => data, error: (f) => throw f);
  },
);

final monthlyReviewProvider = FutureProvider.autoDispose<MonthlyReviewModel>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final result = await repo.getMonthlyReview();
  return result.when(success: (data) => data, error: (f) => throw f);
});

final noSpendDayProvider = FutureProvider.autoDispose<NoSpendDayModel>((
  ref,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final result = await repo.getNoSpendDay();
  return result.when(success: (data) => data, error: (f) => throw f);
});
