// lib/presentation/screens/analytics/analytics_screen.dart — versi final

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/analytics_provider.dart';
import 'widgets/anomaly_list.dart';
import 'widgets/budget_risk_list.dart';
import 'widgets/financial_health_card.dart';
import 'widgets/monthly_review_card.dart';
import 'widgets/no_spend_day_card.dart';
import 'widgets/saving_recommendation_card.dart';
import 'widgets/spending_alert_card.dart';
import 'widgets/spending_prediction_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Insights')),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.elevated,
        onRefresh: () async {
          ref.invalidate(spendingAlertProvider);
          ref.invalidate(budgetRiskProvider);
          ref.invalidate(spendingPredictionProvider);
          ref.invalidate(savingRecommendationProvider);
          ref.invalidate(financialHealthProvider);
          ref.invalidate(anomalyDetectionProvider);
          ref.invalidate(monthlyReviewProvider);
          ref.invalidate(noSpendDayProvider);
          await ref.read(spendingAlertProvider.future).catchError((_) {});
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Spending Alert — paling urgent, taruh paling atas
            const SpendingAlertCard(),

            const SizedBox(height: 20),

            // 2. Financial Health Score
            _sectionTitle('Skor Kesehatan Finansial'),
            const SizedBox(height: 10),
            const FinancialHealthCard(),

            const SizedBox(height: 20),

            // 3. Budget Risk — risiko aktif
            _sectionTitle('Risiko Budget'),
            const SizedBox(height: 10),
            const BudgetRiskList(),

            const SizedBox(height: 20),

            // 4. Spending Prediction — proyeksi bulan ini
            _sectionTitle('Prediksi Pengeluaran'),
            const SizedBox(height: 10),
            const SpendingPredictionCard(),

            const SizedBox(height: 20),

            // 5. Saving Recommendation — rekomendasi per goal
            _sectionTitle('Rekomendasi Tabungan'),
            const SizedBox(height: 10),
            const SavingRecommendationCard(),

            const SizedBox(height: 20),

            // 6. Anomaly Detection — transaksi tidak wajar
            _sectionTitle('Transaksi Tidak Wajar'),
            const SizedBox(height: 10),
            const AnomalyList(),

            const SizedBox(height: 20),

            // 7. No Spend Day — streak
            _sectionTitle('No-Spend Streak'),
            const SizedBox(height: 10),
            const NoSpendDayCard(),

            const SizedBox(height: 20),

            // 8. Monthly Review — laporan bulan lalu
            _sectionTitle('Ulasan Bulan Lalu'),
            const SizedBox(height: 10),
            const MonthlyReviewCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.sectionTitle,
    );
  }
}