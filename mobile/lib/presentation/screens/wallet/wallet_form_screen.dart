// lib/presentation/screens/wallet/wallet_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/wallet_model.dart';
import '../../../providers/wallet_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class WalletFormScreen extends ConsumerStatefulWidget {
  final WalletModel? wallet;

  const WalletFormScreen({super.key, this.wallet});

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'cash';

  bool get _isEdit => widget.wallet != null;

  static const _types = [
    {'value': 'cash', 'label': 'Tunai'},
    {'value': 'bank', 'label': 'Bank'},
    {'value': 'e-wallet', 'label': 'E-Wallet'},
    {'value': 'investment', 'label': 'Investasi'},
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.wallet!.name;
      _selectedType = widget.wallet!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {'name': _nameController.text.trim(), 'type': _selectedType};
    bool success;

    if (_isEdit) {
      success = await ref
          .read(walletProvider.notifier)
          .update(widget.wallet!.id, data);
    } else {
      success = await ref.read(walletProvider.notifier).create(data);
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Wallet berhasil diperbarui.' : 'Wallet berhasil dibuat.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(walletProvider).errorMessage ?? 'Terjadi kesalahan.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Wallet' : 'Tambah Wallet'),
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
                label: 'Nama Wallet',
                controller: _nameController,
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),

              const SizedBox(height: 20),

              const Text(
                'Tipe Wallet',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: _types.map((t) {
                  final isSelected = _selectedType == t['value'];
                  return ChoiceChip(
                    label: Text(t['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedType = t['value']!),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              CustomButton(
                label: _isEdit ? 'Simpan Perubahan' : 'Buat Wallet',
                onPressed: _handleSubmit,
                isLoading: state.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}