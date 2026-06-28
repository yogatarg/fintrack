// lib/presentation/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/balance_card.dart';
import '../../widgets/dashboard/expense_chart.dart';
import '../../widgets/dashboard/monthly_trend_chart.dart';
import '../analytics/analytics_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).fetch(),
          color: AppColors.primary,
          backgroundColor: AppColors.elevated,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hai, ${user?.name.split(' ').first ?? ''}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Berikut ringkasan keuangan Anda',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      _buildAvatar(user?.name ?? 'U'),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: state.isLoading
                      ? _buildSkeletons()
                      : state.errorMessage != null
                      ? _buildError(
                          state.errorMessage!,
                          () => ref.read(dashboardProvider.notifier).fetch(),
                        )
                      : _buildContent(context, state.data!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BalanceCard(
          totalBalance: dashboard.totalBalance,
          monthlyIncome: dashboard.monthlyIncome,
          monthlyExpense: dashboard.monthlyExpense,
          monthlyNet: dashboard.monthlyNet,
        ),

        const SizedBox(height: 16),

        // Smart Insights Banner
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1442),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFFA78BFA), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lihat analitik & insight keuangan Anda',
                    style: TextStyle(
                      color: Color(0xFFA78BFA),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF7C3AED), size: 18),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        _buildSectionHeader('Pengeluaran per Kategori'),
        const SizedBox(height: 12),
        _buildCard(child: ExpenseChart(data: dashboard.expenseByCategory)),

        const SizedBox(height: 28),

        _buildSectionHeader('Tren 6 Bulan Terakhir'),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildLegend(AppColors.income, 'Pemasukan'),
            const SizedBox(width: 16),
            _buildLegend(AppColors.expense, 'Pengeluaran'),
          ],
        ),
        const SizedBox(height: 12),
        _buildCard(child: MonthlyTrendChart(data: dashboard.monthlyTrend)),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title.toUpperCase(), style: AppTextStyles.sectionTitle);
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: child,
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }

  Widget _buildSkeletons() {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: i == 0 ? 200 : 140,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
