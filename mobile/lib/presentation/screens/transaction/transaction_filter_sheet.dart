// lib/presentation/screens/transaction/transaction_filter_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../core/utils/date_picker_helper.dart';

class TransactionFilterSheet extends ConsumerStatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  ConsumerState<TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState
    extends ConsumerState<TransactionFilterSheet> {
  String? _type;
  int? _walletId;
  int? _categoryId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final current = ref.read(transactionProvider).filter;
    _type = current.type;
    _walletId = current.walletId;
    _categoryId = current.categoryId;
    _startDate = current.startDate != null
        ? DateTime.parse(current.startDate!)
        : null;
    _endDate = current.endDate != null
        ? DateTime.parse(current.endDate!)
        : null;
  }

  Future<void> _pickDateRange() async {
    final range = await showAppDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    }
  }

  void _applyFilter() {
    final filter = TransactionFilter(
      type: _type,
      walletId: _walletId,
      categoryId: _categoryId,
      startDate: _startDate != null
          ? DateFormatter.toApiFormat(_startDate!)
          : null,
      endDate: _endDate != null ? DateFormatter.toApiFormat(_endDate!) : null,
    );

    ref.read(transactionProvider.notifier).fetch(newFilter: filter);
    Navigator.pop(context);
  }

  void _resetFilter() {
    ref
        .read(transactionProvider.notifier)
        .fetch(newFilter: const TransactionFilter());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final categoryState = ref.watch(categoryProvider);

    if (walletState.isLoading || categoryState.isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final wallets = walletState.wallets;
    final categories = categoryState.categories;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter Transaksi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Type filter
          const Text('Tipe', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua'),
                selected: _type == null,
                onSelected: (_) => setState(() => _type = null),
              ),
              ChoiceChip(
                label: const Text('Pemasukan'),
                selected: _type == 'income',
                onSelected: (_) => setState(() => _type = 'income'),
              ),
              ChoiceChip(
                label: const Text('Pengeluaran'),
                selected: _type == 'expense',
                onSelected: (_) => setState(() => _type = 'expense'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Wallet filter
          const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            value: _walletId,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            iconEnabledColor: AppColors.textMuted,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 0.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            hint: const Text(
              'Semua Wallet',
              style: TextStyle(color: AppColors.textMuted),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(
                  'Semua Wallet',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              ...wallets.map(
                (w) => DropdownMenuItem(
                  value: w.id,
                  child: Text(
                    w.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _walletId = v),
          ),

          const SizedBox(height: 16),

          // Category filter
          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            value: _categoryId,
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            iconEnabledColor: AppColors.textMuted,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 0.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            hint: const Text(
              'Semua Kategori',
              style: TextStyle(color: AppColors.textMuted),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text(
                  'Semua Kategori',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              ...categories.map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(
                    c.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _categoryId = v),
          ),

          const SizedBox(height: 16),

          // Date range
          const Text('Periode', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDateRange,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormatter.toApiFormat(_startDate!)} → ${DateFormatter.toApiFormat(_endDate!)}'
                  : 'Pilih Rentang Tanggal',
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilter,
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
