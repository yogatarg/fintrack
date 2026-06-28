// lib/presentation/screens/analytics/widgets/monthly_review_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../providers/analytics_provider.dart';
import 'analytics_error_state.dart';

class MonthlyReviewCard extends ConsumerWidget {
  const MonthlyReviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(monthlyReviewProvider);

    return asyncValue.when(
      loading: () => _buildSkeleton(),
      error: (err, _) => AnalyticsErrorState(error: err),
      data: (review) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan ${review.period}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      'Pemasukan',
                      review.totalIncome,
                      AppColors.income,
                    ),
                  ),
                  Expanded(
                    child: _buildStat(
                      'Pengeluaran',
                      review.totalExpense,
                      AppColors.expense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      'Tabungan',
                      review.totalSaving,
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildStat(
                      'Saving Rate',
                      null,
                      AppColors.primary,
                      customValue: '${review.savingRate.toStringAsFixed(1)}%',
                    ),
                  ),
                ],
              ),
              if (review.topCategories.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Kategori Terbesar',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ...review.topCategories
                    .take(3)
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.categoryName,
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              CurrencyFormatter.format(c.total),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(
    String label,
    double? value,
    Color color, {
    String? customValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          customValue ?? CurrencyFormatter.format(value ?? 0),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
