// lib/presentation/screens/budget/budget_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/budget_model.dart';
import '../../../providers/budget_provider.dart';
import '../../widgets/common/app_card.dart';
import 'budget_form_screen.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

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

  String _riskLabel(String risk) {
    switch (risk) {
      case 'over':
        return 'Melebihi Budget';
      case 'high':
        return 'Risiko Tinggi';
      case 'medium':
        return 'Perlu Diperhatikan';
      default:
        return 'Aman';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BudgetFormScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.budgets.isEmpty
          ? Center(child: Text(state.errorMessage!))
          : state.budgets.isEmpty
          ? const Center(
              child: Text(
                'Belum ada budget.\nBuat budget untuk mengontrol pengeluaran.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(budgetProvider.notifier).fetch(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.budgets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildBudgetCard(context, ref, state.budgets[index]),
              ),
            ),
    );
  }

  Widget _buildBudgetCard(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) {
    final riskColor = _riskColor(budget.riskLevel);
    final progress = (budget.usagePercentage / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BudgetFormScreen(budget: budget)),
        ),
        onLongPress: () => _showDeleteDialog(context, ref, budget),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _riskLabel(budget.riskLevel),
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.elevated,
                color: riskColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyFormatter.format(budget.spentAmount)} dari ${CurrencyFormatter.format(budget.amount)}',
                  style: AppTextStyles.label,
                ),
                Text(
                  '${budget.usagePercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    BudgetModel budget,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Budget'),
        content: Text(
          'Yakin ingin menghapus budget "${budget.category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(budgetProvider.notifier)
                  .delete(budget.id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(budgetProvider).errorMessage ??
                          'Gagal menghapus budget.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
