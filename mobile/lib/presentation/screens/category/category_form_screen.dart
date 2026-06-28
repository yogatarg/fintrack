// lib/presentation/screens/category/category_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const CategoryFormScreen({super.key, this.category});

  @override
  ConsumerState<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'expense';

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.category!.name;
      _selectedType = widget.category!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'type': _selectedType,
    };

    bool success;
    if (_isEdit) {
      success = await ref
          .read(categoryProvider.notifier)
          .update(widget.category!.id, data);
    } else {
      success = await ref.read(categoryProvider.notifier).create(data);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Kategori berhasil diperbarui.'
                : 'Kategori berhasil dibuat.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(categoryProvider).errorMessage ?? 'Terjadi kesalahan.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
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
                label: 'Nama Kategori',
                controller: _nameController,
                prefixIcon: const Icon(Icons.label_outline),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),

              const SizedBox(height: 20),

              const Text(
                'Tipe',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton('expense', 'Pengeluaran',
                        AppColors.expense),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeButton('income', 'Pemasukan',
                        AppColors.income),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              CustomButton(
                label: _isEdit ? 'Simpan Perubahan' : 'Buat Kategori',
                onPressed: _handleSubmit,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String value, String label, Color color) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
          ),
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