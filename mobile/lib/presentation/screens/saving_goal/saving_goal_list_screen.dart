// lib/presentation/screens/saving_goal/saving_goal_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/saving_goal_model.dart';
import '../../../providers/saving_goal_provider.dart';
import 'add_progress_sheet.dart';
import 'saving_goal_form_screen.dart';

class SavingGoalListScreen extends ConsumerWidget {
  const SavingGoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savingGoalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavingGoalFormScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.goals.isEmpty
          ? Center(child: Text(state.errorMessage!))
          : state.goals.isEmpty
          ? const Center(
              child: Text(
                'Belum ada target tabungan.\nMulai menabung untuk tujuan Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(savingGoalProvider.notifier).fetch(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.activeGoals.isNotEmpty) ...[
                    const Text(
                      'Aktif',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...state.activeGoals.map(
                      (g) => _buildGoalCard(context, ref, g),
                    ),
                  ],
                  if (state.completedGoals.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Tercapai',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...state.completedGoals.map(
                      (g) => _buildGoalCard(context, ref, g),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref,
    SavingGoalModel goal,
  ) {
    final isCompleted = goal.status == 'completed';
    final progress = (goal.progressPercentage / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: isCompleted
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavingGoalFormScreen(goal: goal),
                ),
              ),
        onLongPress: () => _showDeleteDialog(context, ref, goal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.savings_outlined,
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (!isCompleted && !goal.isOnTrack)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.riskMedium.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tertinggal',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.riskMedium,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: isCompleted ? AppColors.primary : AppColors.income,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${CurrencyFormatter.format(goal.currentAmount)} / ${CurrencyFormatter.format(goal.targetAmount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true, // ← ini yang paling penting
                    backgroundColor: Colors.transparent,
                    builder: (_) => AddProgressSheet(goal: goal),
                  ),
                  child: const Text('Tambah Tabungan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    SavingGoalModel goal,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Target Tabungan'),
        content: Text('Yakin ingin menghapus target "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(savingGoalProvider.notifier)
                  .delete(goal.id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(savingGoalProvider).errorMessage ??
                          'Gagal menghapus target.',
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
