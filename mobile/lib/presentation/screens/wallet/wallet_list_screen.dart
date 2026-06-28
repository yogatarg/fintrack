// lib/presentation/screens/wallet/wallet_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/wallet_model.dart';
import '../../../providers/wallet_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/section_header.dart';
import 'wallet_form_screen.dart';

class WalletListScreen extends ConsumerWidget {
  const WalletListScreen({super.key});

  static const _typeLabels = {
    'cash': 'Tunai',
    'bank': 'Bank',
    'e-wallet': 'E-Wallet',
    'investment': 'Investasi',
  };

  static const _typeIcons = {
    'cash': Icons.payments_outlined,
    'bank': Icons.account_balance_outlined,
    'e-wallet': Icons.phone_android_outlined,
    'investment': Icons.trending_up_outlined,
  };

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletFormScreen()),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(walletProvider.notifier).fetch(),
              color: AppColors.primary,
              backgroundColor: AppColors.elevated,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Total card
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Saldo', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(state.totalBalance),
                          style: AppTextStyles.heroAmount,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.wallets.length} wallet terhubung',
                          style: AppTextStyles.label,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (state.wallets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 40,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada wallet.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WalletFormScreen(),
                                ),
                              ),
                              child: const Text('Tambah Wallet'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    const SectionHeader(title: 'Daftar Wallet'),
                    const SizedBox(height: 12),
                    ...state.wallets.map(
                      (w) => _buildWalletItem(context, ref, w),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildWalletItem(BuildContext context, WidgetRef ref, WalletModel w) {
    final color = _parseColor(w.color);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WalletFormScreen(wallet: w)),
      ),
      onLongPress: () => _showDeleteDialog(context, ref, w),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(
              _typeIcons[w.type] ?? Icons.account_balance_wallet_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _typeLabels[w.type] ?? w.type,
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(w.balance),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(w.currency, style: AppTextStyles.label),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, WalletModel w) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Wallet', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Yakin ingin menghapus "${w.name}"?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(walletProvider.notifier).delete(w.id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }
}