// lib/presentation/widgets/dashboard/balance_card.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyNet;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlyNet,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Saldo', style: AppTextStyles.label),
              GestureDetector(
                onTap: () => setState(() => _hidden = !_hidden),
                child: Icon(
                  _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Balance Amount
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _hidden
                ? const Text(
                    '••••••••',
                    key: ValueKey('hidden'),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: -0.5,
                    ),
                  )
                : Text(
                    CurrencyFormatter.format(widget.totalBalance),
                    key: const ValueKey('shown'),
                    style: AppTextStyles.heroAmount,
                  ),
          ),

          const SizedBox(height: 28),

          // Divider
          const Divider(height: 1),

          const SizedBox(height: 20),

          // Income / Expense Row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Pemasukan',
                  amount: widget.monthlyIncome,
                  color: AppColors.income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              Container(
                width: 0.5,
                height: 40,
                color: AppColors.border,
              ),
              Expanded(
                child: _StatItem(
                  label: 'Pengeluaran',
                  amount: widget.monthlyExpense,
                  color: AppColors.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Net bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sisa bulan ini', style: AppTextStyles.label),
                Text(
                  CurrencyFormatter.format(widget.monthlyNet),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.monthlyNet >= 0
                        ? AppColors.income
                        : AppColors.expense,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}