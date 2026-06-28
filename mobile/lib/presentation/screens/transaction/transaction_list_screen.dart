// lib/presentation/screens/transaction/transaction_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../widgets/common/app_card.dart';
import 'transaction_filter_sheet.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _scrollController = ScrollController();
  bool _isFetchingMore = false; // guard lokal, sinkron

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isFetchingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isFetchingMore = true;
      ref.read(transactionProvider.notifier).loadMore().whenComplete(() {
        _isFetchingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _parseColor(String? hex) {
    if (hex == null) return AppColors.primary;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  String _groupLabel(String date) {
    final txDate = DateTime.parse(date);
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(txDate, today)) return 'Hari Ini';
    if (_isSameDay(txDate, yesterday)) return 'Kemarin';
    return DateFormatter.toDisplay(date);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionProvider);

    // Group transactions by date
    final grouped = <String, List<TransactionModel>>{};
    for (final t in state.items) {
      grouped.putIfAbsent(t.transactionDate, () => []).add(t);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: state.filter.isEmpty
                  ? AppColors.textPrimary
                  : AppColors.primary,
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => const TransactionFilterSheet(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
          if (result == true) {
            ref.invalidate(transactionProvider);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.items.isEmpty
          ? Center(child: Text(state.errorMessage!))
          : state.items.isEmpty
          ? const Center(
              child: Text(
                'Belum ada transaksi.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(transactionProvider.notifier).fetch(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: sortedDates.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == sortedDates.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final date = sortedDates[index];
                  final dayTransactions = grouped[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                          _groupLabel(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...dayTransactions.map((t) => _buildTransactionItem(t)),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildTransactionItem(TransactionModel t) {
    final isIncome = t.type == 'income';
    final color = isIncome ? AppColors.income : AppColors.expense;
    final categoryColor = _parseColor(t.category.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionFormScreen(transaction: t),
            ),
          );
          if (result == true) ref.invalidate(transactionProvider);
        },
        onLongPress: () => _showDeleteDialog(t),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.label, color: categoryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.wallet.name}${t.note != null && t.note!.isNotEmpty ? ' · ${t.note}' : ''}',
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '−'} ${CurrencyFormatter.format(t.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(TransactionModel t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(transactionProvider.notifier)
                  .delete(t.id);
              if (success) {
                ref.invalidate(transactionProvider);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menghapus transaksi.'),
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
