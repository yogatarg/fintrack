// lib/data/models/wallet_model.dart

class WalletModel {
  final int id;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final String? createdAt;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
    this.createdAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'IDR',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  WalletModel copyWith({
    String? name,
    String? type,
    double? balance,
    String? icon,
    String? color,
  }) {
    return WalletModel(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }
}