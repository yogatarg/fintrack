// lib/presentation/screens/analytics/widgets/spending_alert_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../providers/analytics_provider.dart';

class SpendingAlertCard extends ConsumerWidget {
  const SpendingAlertCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(spendingAlertProvider);

    return asyncValue.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (!data.isAlertTriggered) return const SizedBox.shrink();

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Peringatan Pengeluaran Hari Ini',
                    style: AppTextStyles.sectionTitle,
                  ),
                  Text(
                    CurrencyFormatter.format(data.todaySpending),
                    style: AppTextStyles.mediumAmount,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data.message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'Rata-rata harian: ${CurrencyFormatter.format(data.dailyAverage)}',
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${data.percentageAboveAverage.toStringAsFixed(1)}%)',
                    style: const TextStyle(color: AppColors.expense),
                  ),
                ],
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
