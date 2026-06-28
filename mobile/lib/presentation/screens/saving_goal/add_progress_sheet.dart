// lib/presentation/screens/saving_goal/add_progress_sheet.dart — full rewrite

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/saving_goal_model.dart';
import '../../../providers/saving_goal_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddProgressSheet extends ConsumerStatefulWidget {
  final SavingGoalModel goal;

  const AddProgressSheet({super.key, required this.goal});

  @override
  ConsumerState<AddProgressSheet> createState() => _AddProgressSheetState();
}

class _AddProgressSheetState extends ConsumerState<AddProgressSheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final amount = double.parse(_amountController.text);
    final success = await ref
        .read(savingGoalProvider.notifier)
        .addProgress(widget.goal.id, amount);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress berhasil ditambahkan.')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(savingGoalProvider).errorMessage ?? 'Terjadi kesalahan.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sisa = widget.goal.remainingAmount;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Padding bawah = keyboard height + safe area + extra breathing room
      padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 24),
      child: SingleChildScrollView(
        // ← wrap dengan scroll agar tidak overflow saat keyboard muncul
        physics: const NeverScrollableScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                widget.goal.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Sisa target: ${CurrencyFormatter.format(sisa)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (widget.goal.progressPercentage / 100).clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: AppColors.elevated,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              CustomTextField(
                label: 'Jumlah yang ditabung',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.savings_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  final amount = double.tryParse(v);
                  if (amount == null || amount < 1000) {
                    return 'Jumlah minimal Rp1.000';
                  }
                  if (sisa > 0 && amount > sisa) {
                    return 'Melebihi sisa target (${CurrencyFormatter.format(sisa)})';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: _quickAmounts(sisa).map((amount) {
                  return ActionChip(
                    label: Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    backgroundColor: AppColors.elevated,
                    side: const BorderSide(color: AppColors.border),
                    onPressed: () {
                      _amountController.text = amount.toStringAsFixed(0);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(0, 52),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Tambahkan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),

              // Extra padding di bawah agar tidak terpotong gesture bar
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Quick amount suggestions berdasarkan sisa target
  List<double> _quickAmounts(double sisa) {
    if (sisa <= 0) return [];

    final suggestions = <double>[];

    // 25%, 50%, 100% dari sisa
    final pct25 = (sisa * 0.25).roundToDouble();
    final pct50 = (sisa * 0.5).roundToDouble();

    if (pct25 >= 1000) suggestions.add(pct25);
    if (pct50 >= 1000 && pct50 != pct25) suggestions.add(pct50);
    if (sisa >= 1000) suggestions.add(sisa); // lunasi sekaligus

    // Batasi 3 chip saja
    return suggestions.take(3).toList();
  }
}
