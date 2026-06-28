// lib/presentation/screens/transaction/transaction_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/utils/date_picker_helper.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  int? _walletId;
  int? _categoryId;
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  bool get _isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.transaction!;
      _type = t.type;
      _amountController.text = t.amount.toStringAsFixed(0);
      _noteController.text = t.note ?? '';
      _walletId = t.wallet.id;
      _categoryId = t.category.id;
      _date = DateTime.parse(t.transactionDate);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return; // guard tambahan
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null) {
      _showSnack('Pilih wallet terlebih dahulu.', isError: true);
      return;
    }
    if (_categoryId == null) {
      _showSnack('Pilih kategori terlebih dahulu.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'wallet_id': _walletId,
      'category_id': _categoryId,
      'type': _type,
      'amount': double.parse(_amountController.text),
      'note': _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      'transaction_date': DateFormatter.toApiFormat(_date),
    };

    bool success;
    if (_isEdit) {
      success = await ref
          .read(transactionProvider.notifier)
          .update(widget.transaction!.id, data);
    } else {
      success = await ref.read(transactionProvider.notifier).create(data);
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      // Penting: refresh dashboard karena balance/summary berubah
      ref.invalidate(dashboardProvider);
      ref.invalidate(walletProvider);

      Navigator.pop(context, true);
      _showSnack(
        _isEdit
            ? 'Transaksi berhasil diperbarui.'
            : 'Transaksi berhasil ditambahkan.',
      );
    } else if (mounted) {
      _showSnack(
        ref.read(transactionProvider).errorMessage ?? 'Terjadi kesalahan.',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final categoryState = ref.watch(categoryProvider);

    // Guard: tampilkan loading jika data master belum siap
    if (walletState.isLoading || categoryState.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Guard: wallet kosong → tidak bisa buat transaksi
    if (walletState.wallets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah Transaksi')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda belum memiliki wallet.\nBuat wallet terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final wallets = walletState.wallets;
    final categories = categoryState.categories
        .where((c) => c.type == _type)
        .toList();

    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      'expense',
                      'Pengeluaran',
                      AppColors.expense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton(
                      'income',
                      'Pemasukan',
                      AppColors.income,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              CustomTextField(
                label: 'Jumlah',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.payments_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Jumlah tidak boleh kosong';
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Wallet dropdown
              const Text(
                'Wallet',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _walletId,
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
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
                  'Pilih Wallet',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                items: wallets
                    .map(
                      (w) => DropdownMenuItem(
                        value: w.id,
                        child: Text(
                          w.name,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _walletId = v),
              ),

              const SizedBox(height: 16),

              // Category dropdown
              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _categoryId,
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
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
                  'Pilih Kategori',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),

              const SizedBox(height: 16),

              // Date picker
              const Text(
                'Tanggal',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 10),
                      Text(DateFormatter.toApiFormat(_date)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Catatan (opsional)',
                controller: _noteController,
                prefixIcon: const Icon(Icons.note_outlined),
              ),

              const SizedBox(height: 32),

              CustomButton(
                label: _isEdit ? 'Simpan Perubahan' : 'Tambah Transaksi',
                onPressed: _handleSubmit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String value, String label, Color color) {
    final isSelected = _type == value;
    return GestureDetector(
      onTap: () => setState(() => _type = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
