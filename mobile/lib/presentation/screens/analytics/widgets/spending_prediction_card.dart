// lib/presentation/screens/analytics/widgets/spending_prediction_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../providers/analytics_provider.dart';

class SpendingPredictionCard extends ConsumerWidget {
  const SpendingPredictionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(spendingPredictionProvider);

    return asyncValue.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.currentSpending == 0) return const SizedBox.shrink();

        final isHigher = data.percentageDifference > 0;
        final diffColor = isHigher ? AppColors.expense : AppColors.income;
        final diffLabel = isHigher ? '↑' : '↓';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PREDIKSI AKHIR BULAN', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 12),
              Text(
                CurrencyFormatter.format(data.predictedTotal),
                style: AppTextStyles.mediumAmount,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '$diffLabel ${data.percentageDifference.abs().toStringAsFixed(1)}% vs bulan lalu',
                    style: TextStyle(
                      fontSize: 12,
                      color: diffColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${data.daysRemaining} hari lagi',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}