// lib/data/models/budget_model.dart

class BudgetCategoryRef {
  final int id;
  final String name;
  final String? icon;
  final String? color;

  const BudgetCategoryRef({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory BudgetCategoryRef.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryRef(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}

class BudgetModel {
  final int id;
  final double amount;
  final double spentAmount;
  final String periodStart;
  final String periodEnd;
  final BudgetCategoryRef category;
  final double remainingAmount;
  final double usagePercentage;
  final bool isOverBudget;
  final String riskLevel;

  const BudgetModel({
    required this.id,
    required this.amount,
    required this.spentAmount,
    required this.periodStart,
    required this.periodEnd,
    required this.category,
    required this.remainingAmount,
    required this.usagePercentage,
    required this.isOverBudget,
    required this.riskLevel,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      spentAmount: (json['spent_amount'] as num).toDouble(),
      periodStart: json['period_start'] as String,
      periodEnd: json['period_end'] as String,
      category: BudgetCategoryRef.fromJson(json['category']),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      usagePercentage: (json['usage_percentage'] as num).toDouble(),
      isOverBudget: json['is_over_budget'] as bool,
      riskLevel: json['risk_level'] as String? ?? 'low',
    );
  }
}