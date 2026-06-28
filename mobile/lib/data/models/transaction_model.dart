// lib/data/models/transaction_model.dart

class TransactionWalletRef {
  final int id;
  final String name;
  final String type;

  const TransactionWalletRef({
    required this.id,
    required this.name,
    required this.type,
  });

  factory TransactionWalletRef.fromJson(Map<String, dynamic> json) {
    return TransactionWalletRef(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }
}

class TransactionCategoryRef {
  final int id;
  final String name;
  final String type;
  final String? icon;
  final String? color;

  const TransactionCategoryRef({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
  });

  factory TransactionCategoryRef.fromJson(Map<String, dynamic> json) {
    return TransactionCategoryRef(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}

class TransactionModel {
  final int id;
  final String type;
  final double amount;
  final String? note;
  final String transactionDate;
  final TransactionWalletRef wallet;
  final TransactionCategoryRef category;
  final String? createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.wallet,
    required this.category,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      transactionDate: json['transaction_date'] as String,
      wallet: TransactionWalletRef.fromJson(json['wallet']),
      category: TransactionCategoryRef.fromJson(json['category']),
      createdAt: json['created_at'] as String?,
    );
  }
}

class TransactionPageModel {
  final List<TransactionModel> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const TransactionPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;
}