// lib/presentation/screens/saving_goal/saving_goal_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/saving_goal_model.dart';
import '../../../providers/saving_goal_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../core/utils/date_picker_helper.dart';

class SavingGoalFormScreen extends ConsumerStatefulWidget {
  final SavingGoalModel? goal;

  const SavingGoalFormScreen({super.key, this.goal});

  @override
  ConsumerState<SavingGoalFormScreen> createState() =>
      _SavingGoalFormScreenState();
}

class _SavingGoalFormScreenState extends ConsumerState<SavingGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 365));
  bool _isSubmitting = false;

  bool get _isEdit => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final g = widget.goal!;
      _nameController.text = g.name;
      _targetController.text = g.targetAmount.toStringAsFixed(0);
      _deadline = DateTime.parse(g.deadline);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'name': _nameController.text.trim(),
      'target_amount': double.parse(_targetController.text),
      'deadline': DateFormatter.toApiFormat(_deadline),
    };

    bool success;
    if (_isEdit) {
      success = await ref
          .read(savingGoalProvider.notifier)
          .update(widget.goal!.id, data);
    } else {
      success = await ref.read(savingGoalProvider.notifier).create(data);
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Target berhasil diperbarui.' : 'Target berhasil dibuat.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(savingGoalProvider).errorMessage ?? 'Terjadi kesalahan.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Target' : 'Buat Target Tabungan'),
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
              CustomTextField(
                label: 'Nama Target',
                controller: _nameController,
                prefixIcon: const Icon(Icons.flag_outlined),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Target Nominal',
                controller: _targetController,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.savings_outlined),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Target tidak boleh kosong';
                  final amount = double.tryParse(v);
                  if (amount == null || amount < 1000) {
                    return 'Target minimal Rp1.000';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Deadline',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDeadline,
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
                      Text(DateFormatter.toApiFormat(_deadline)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              CustomButton(
                label: _isEdit ? 'Simpan Perubahan' : 'Buat Target',
                onPressed: _handleSubmit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
