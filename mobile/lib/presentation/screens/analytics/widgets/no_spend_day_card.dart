// lib/presentation/screens/analytics/widgets/no_spend_day_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/analytics_provider.dart';
import 'analytics_error_state.dart';

class NoSpendDayCard extends ConsumerWidget {
  const NoSpendDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(noSpendDayProvider);

    return asyncValue.when(
      loading: () => _buildSkeleton(),
      error: (err, _) => AnalyticsErrorState(error: err),
      data: (data) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${data.currentStreak.abs()}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text('hari streak', style: TextStyle(fontSize: 11)),
                ],
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${data.currentStreak.abs()}', // abs() untuk antisipasi nilai negatif
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
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
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
