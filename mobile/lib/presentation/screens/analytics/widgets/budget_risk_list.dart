// lib/presentation/screens/analytics/widgets/budget_risk_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/analytics_provider.dart';
import 'analytics_error_state.dart';

class BudgetRiskList extends ConsumerWidget {
  const BudgetRiskList({super.key});

  Color _riskColor(String risk) {
    switch (risk) {
      case 'over':
        return AppColors.riskOver;
      case 'high':
        return AppColors.riskHigh;
      case 'medium':
        return AppColors.riskMedium;
      default:
        return AppColors.riskLow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(budgetRiskProvider);

    return asyncValue.when(
      loading: () => _buildSkeleton(),
      error: (err, _) => AnalyticsErrorState(error: err),
      data: (risks) {
        if (risks.isEmpty) return const SizedBox.shrink();

        // Hanya tampilkan yang berisiko (medium, high, over)
        final relevantRisks = risks.where((r) => r.riskLevel != 'low').toList();

        if (relevantRisks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: relevantRisks.map((risk) {
            final color = _riskColor(risk.riskLevel);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.pie_chart, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      risk.message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
