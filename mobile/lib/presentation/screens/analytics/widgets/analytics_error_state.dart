import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';

class AnalyticsErrorState extends StatelessWidget {
  final Object error;

  const AnalyticsErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error is NetworkFailure) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textMuted, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data tidak tersedia saat ini.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
