// lib/data/models/dashboard_model.dart

class ExpenseByCategoryModel {
  final int categoryId;
  final String categoryName;
  final String color;
  final double total;

  const ExpenseByCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.total,
  });

  factory ExpenseByCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategoryModel(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      color: json['color'] as String? ?? '#607D8B',
      total: (json['total'] as num).toDouble(),
    );
  }
}

class MonthlyTrendModel {
  final String month;
  final String label;
  final double income;
  final double expense;
  final double net;

  const MonthlyTrendModel({
    required this.month,
    required this.label,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory MonthlyTrendModel.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendModel(
      month: json['month'] as String,
      label: json['label'] as String,
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
    );
  }
}

class DashboardModel {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyNet;
  final List<ExpenseByCategoryModel> expenseByCategory;
  final List<MonthlyTrendModel> monthlyTrend;

  const DashboardModel({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlyNet,
    required this.expenseByCategory,
    required this.monthlyTrend,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalBalance: (json['total_balance'] as num).toDouble(),
      monthlyIncome: (json['monthly_income'] as num).toDouble(),
      monthlyExpense: (json['monthly_expense'] as num).toDouble(),
      monthlyNet: (json['monthly_net'] as num).toDouble(),
      expenseByCategory: (json['expense_by_category'] as List)
          .map((e) => ExpenseByCategoryModel.fromJson(e))
          .toList(),
      monthlyTrend: (json['monthly_trend'] as List)
          .map((e) => MonthlyTrendModel.fromJson(e))
          .toList(),
    );
  }
}