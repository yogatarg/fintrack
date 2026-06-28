// lib/data/models/analytics_model.dart

class SpendingAlertModel {
  final bool isAlertTriggered;
  final double todaySpending;
  final double dailyAverage;
  final double percentageAboveAverage;
  final String message;

  const SpendingAlertModel({
    required this.isAlertTriggered,
    required this.todaySpending,
    required this.dailyAverage,
    required this.percentageAboveAverage,
    required this.message,
  });

  factory SpendingAlertModel.fromJson(Map<String, dynamic> json) {
    return SpendingAlertModel(
      isAlertTriggered: json['is_alert_triggered'] as bool? ?? false,
      todaySpending: (json['today_spending'] as num?)?.toDouble() ?? 0,
      dailyAverage: (json['daily_average'] as num?)?.toDouble() ?? 0,
      percentageAboveAverage:
          (json['percentage_above_average'] as num?)?.toDouble() ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}

class BudgetRiskModel {
  final int budgetId;
  final String categoryName;
  final double usagePercentage;
  final double periodProgressPercentage;
  final String riskLevel;
  final String message;

  const BudgetRiskModel({
    required this.budgetId,
    required this.categoryName,
    required this.usagePercentage,
    required this.periodProgressPercentage,
    required this.riskLevel,
    required this.message,
  });

  factory BudgetRiskModel.fromJson(Map<String, dynamic> json) {
    return BudgetRiskModel(
      budgetId: json['budget_id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? '-',
      usagePercentage: (json['usage_percentage'] as num?)?.toDouble() ?? 0,
      periodProgressPercentage:
          (json['period_progress_percentage'] as num?)?.toDouble() ?? 0,
      riskLevel: json['risk_level'] as String? ?? 'low',
      message: json['message'] as String? ?? '',
    );
  }
}

class SpendingPredictionModel {
  final double currentSpending;
  final double dailyAverage;
  final double predictedTotal;
  final double lastMonthSpending;
  final double percentageDifference;
  final int daysRemaining;
  final String message;

  const SpendingPredictionModel({
    required this.currentSpending,
    required this.dailyAverage,
    required this.predictedTotal,
    required this.lastMonthSpending,
    required this.percentageDifference,
    required this.daysRemaining,
    required this.message,
  });

  factory SpendingPredictionModel.fromJson(Map<String, dynamic> json) {
    return SpendingPredictionModel(
      currentSpending: (json['current_spending'] as num?)?.toDouble() ?? 0,
      dailyAverage: (json['daily_average'] as num?)?.toDouble() ?? 0,
      predictedTotal: (json['predicted_total'] as num?)?.toDouble() ?? 0,
      lastMonthSpending: (json['last_month_spending'] as num?)?.toDouble() ?? 0,
      percentageDifference:
          (json['percentage_difference'] as num?)?.toDouble() ?? 0,
      daysRemaining: json['days_remaining'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}

class SavingRecommendationModel {
  final int goalId;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final double remainingAmount;
  final String deadline;
  final int monthsRemaining;
  final double monthlyRequired;
  final double weeklyRequired;
  final bool isAchievable;
  final String message;

  const SavingRecommendationModel({
    required this.goalId,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    required this.remainingAmount,
    required this.deadline,
    required this.monthsRemaining,
    required this.monthlyRequired,
    required this.weeklyRequired,
    required this.isAchievable,
    required this.message,
  });

  factory SavingRecommendationModel.fromJson(Map<String, dynamic> json) {
    return SavingRecommendationModel(
      goalId: json['goal_id'] as int? ?? 0,
      goalName: json['goal_name'] as String? ?? 'Tidak diketahui',
      targetAmount: (json['target_amount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0,
      deadline: json['deadline'] as String? ?? '',
      monthsRemaining: json['months_remaining'] as int? ?? 0,
      monthlyRequired: (json['monthly_required'] as num?)?.toDouble() ?? 0,
      weeklyRequired: (json['weekly_required'] as num?)?.toDouble() ?? 0,
      isAchievable: json['is_achievable'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }
}

class FinancialHealthModel {
  final int score;
  final String grade;
  final double budgetCompliance;
  final double savingConsistency;
  final double expenseRatio;
  final double financialStability;
  final List<String> insights;

  const FinancialHealthModel({
    required this.score,
    required this.grade,
    required this.budgetCompliance,
    required this.savingConsistency,
    required this.expenseRatio,
    required this.financialStability,
    required this.insights,
  });

  factory FinancialHealthModel.fromJson(Map<String, dynamic> json) {
    return FinancialHealthModel(
      score: json['score'] as int? ?? 0,
      grade: json['grade'] as String? ?? '-',
      budgetCompliance: (json['budget_compliance'] as num?)?.toDouble() ?? 0,
      savingConsistency: (json['saving_consistency'] as num?)?.toDouble() ?? 0,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble() ?? 0,
      financialStability:
          (json['financial_stability'] as num?)?.toDouble() ?? 0,
      insights:
          (json['insights'] as List?)?.whereType<String>().toList() ?? const [],
    );
  }
}

class AnomalyModel {
  final int transactionId;
  final String categoryName;
  final double amount;
  final double normalAverage;
  final double deviationScore;
  final String transactionDate;
  final String message;

  const AnomalyModel({
    required this.transactionId,
    required this.categoryName,
    required this.amount,
    required this.normalAverage,
    required this.deviationScore,
    required this.transactionDate,
    required this.message,
  });

  factory AnomalyModel.fromJson(Map<String, dynamic> json) {
    return AnomalyModel(
      transactionId: json['transaction_id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? 'Tidak diketahui',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      normalAverage: (json['normal_average'] as num?)?.toDouble() ?? 0,
      deviationScore: (json['deviation_score'] as num?)?.toDouble() ?? 0,
      transactionDate: json['transaction_date'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}

class CategorySummaryModel {
  final String categoryName;
  final double total;

  const CategorySummaryModel({required this.categoryName, required this.total});

  factory CategorySummaryModel.fromJson(Map<String, dynamic> json) {
    return CategorySummaryModel(
      categoryName: json['category_name'] as String? ?? 'Tidak diketahui',
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MonthlyReviewModel {
  final String period;
  final double totalIncome;
  final double totalExpense;
  final double totalSaving;
  final double savingRate;
  final List<CategorySummaryModel> topCategories;

  const MonthlyReviewModel({
    required this.period,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSaving,
    required this.savingRate,
    required this.topCategories,
  });

  factory MonthlyReviewModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReviewModel(
      period: json['period'] as String? ?? '',
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0,
      totalSaving: (json['total_saving'] as num?)?.toDouble() ?? 0,
      savingRate: (json['saving_rate'] as num?)?.toDouble() ?? 0,
      topCategories:
          (json['top_categories'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(CategorySummaryModel.fromJson)
              .toList() ??
          const [],
    );
  }
}

class NoSpendDayModel {
  final int noSpendDaysThisMonth;
  final int spendDaysThisMonth;
  final int totalDaysThisMonth;
  final int currentStreak;
  final int longestStreak;
  final String message;

  const NoSpendDayModel({
    required this.noSpendDaysThisMonth,
    required this.spendDaysThisMonth,
    required this.totalDaysThisMonth,
    required this.currentStreak,
    required this.longestStreak,
    required this.message,
  });

  factory NoSpendDayModel.fromJson(Map<String, dynamic> json) {
    return NoSpendDayModel(
      noSpendDaysThisMonth:
          (json['no_spend_days_this_month'] as int?)?.abs() ?? 0,
      spendDaysThisMonth: (json['spend_days_this_month'] as int?)?.abs() ?? 0,
      totalDaysThisMonth: (json['total_days_this_month'] as int?)?.abs() ?? 1,
      currentStreak: (json['current_streak'] as int?)?.abs() ?? 0,
      longestStreak: (json['longest_streak'] as int?)?.abs() ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}
