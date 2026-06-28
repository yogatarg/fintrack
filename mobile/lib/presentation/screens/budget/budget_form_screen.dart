// lib/presentation/screens/budget/budget_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/budget_model.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/category_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/utils/date_picker_helper.dart';

class BudgetFormScreen extends ConsumerStatefulWidget {
  final BudgetModel? budget;

  const BudgetFormScreen({super.key, this.budget});

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  int? _categoryId;
  DateTime _periodStart = DateTime.now().copyWith(day: 1);
  DateTime _periodEnd = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  );
  bool _isSubmitting = false;

  bool get _isEdit => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final b = widget.budget!;
      _amountController.text = b.amount.toStringAsFixed(0);
      _categoryId = b.category.id;
      _periodStart = DateTime.parse(b.periodStart);
      _periodEnd = DateTime.parse(b.periodEnd);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickPeriodStart() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _periodStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _periodStart = picked;
        if (_periodEnd.isBefore(_periodStart)) {
          _periodEnd = DateTime(picked.year, picked.month + 1, 0);
        }
      });
    }
  }

  Future<void> _pickPeriodEnd() async {
    final maxEnd = DateTime(
      _periodStart.year + 1,
      _periodStart.month,
      _periodStart.day,
    );
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _periodEnd,
      firstDate: _periodStart.add(const Duration(days: 1)),
      lastDate: maxEnd,
    );
    if (picked != null) setState(() => _periodEnd = picked);
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      _showSnack('Pilih kategori terlebih dahulu.', isError: true);
      return;
    }

    final data = {
      'category_id': _categoryId,
      'amount': double.parse(_amountController.text),
      'period_start': DateFormatter.toApiFormat(_periodStart),
      'period_end': DateFormatter.toApiFormat(_periodEnd),
    };

    if (!_isEdit) {
      final existingBudgets = ref.read(budgetProvider).budgets;
      final hasOverlap = existingBudgets.any((b) {
        if (b.category.id != _categoryId) return false;
        final existingStart = DateTime.parse(b.periodStart);
        final existingEnd = DateTime.parse(b.periodEnd);
        return _periodStart.isBefore(
              existingEnd.add(const Duration(days: 1)),
            ) &&
            _periodEnd.isAfter(existingStart.subtract(const Duration(days: 1)));
      });

      if (hasOverlap) {
        _showSnack(
          'Budget untuk kategori ini sudah ada di periode yang overlap.',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final bool success;
    if (_isEdit) {
      success = await ref
          .read(budgetProvider.notifier)
          .update(widget.budget!.id, data);
    } else {
      success = await ref.read(budgetProvider.notifier).create(data);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }

    if (success && mounted) {
      Navigator.pop(context);
      _showSnack(
        _isEdit ? 'Budget berhasil diperbarui.' : 'Budget berhasil dibuat.',
      );
    } else if (mounted) {
      _showSnack(
        ref.read(budgetProvider).errorMessage ?? 'Terjadi kesalahan.',
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
    final categoryState = ref.watch(categoryProvider);

    if (categoryState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Edit Budget' : 'Tambah Budget')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Budget hanya untuk kategori expense
    final expenseCategories = categoryState.categories
        .where((c) => c.type == 'expense')
        .toList();

    if (expenseCategories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tambah Budget')),
        body: const Center(
          child: Text(
            'Belum ada kategori pengeluaran.\nBuat kategori terlebih dahulu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Budget' : 'Tambah Budget'),
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
                // Saat edit, kategori tidak bisa diubah (1 budget = 1 kategori per periode)
                items: expenseCategories
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
                onChanged: _isEdit
                    ? null
                    : (v) => setState(() => _categoryId = v),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Jumlah Budget',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Jumlah tidak boleh kosong';
                  final amount = double.tryParse(v);
                  if (amount == null || amount < 1000) {
                    return 'Jumlah minimal Rp1.000';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Periode Mulai',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildDatePicker(_periodStart, _pickPeriodStart),

              const SizedBox(height: 16),

              const Text(
                'Periode Selesai',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildDatePicker(_periodEnd, _pickPeriodEnd),
              const SizedBox(height: 6),
              Text(
                'Periode budget maksimal 1 tahun dari tanggal mulai.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),

              const SizedBox(height: 32),

              CustomButton(
                label: _isEdit ? 'Simpan Perubahan' : 'Buat Budget',
                onPressed: _handleSubmit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 10),
            Text(DateFormatter.toApiFormat(date)),
          ],
        ),
      ),
    );
  }
}
