// lib/data/models/saving_goal_model.dart

class SavingGoalModel {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String deadline;
  final String status;
  final String? icon;
  final String? color;
  final double progressPercentage;
  final double remainingAmount;
  final int daysRemaining;
  final double monthlyRequired;
  final bool isOnTrack;

  const SavingGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.status,
    this.icon,
    this.color,
    required this.progressPercentage,
    required this.remainingAmount,
    required this.daysRemaining,
    required this.monthlyRequired,
    required this.isOnTrack,
  });

  factory SavingGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingGoalModel(
      id: json['id'] as int,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      deadline: json['deadline'] as String,
      status: json['status'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      daysRemaining: json['days_remaining'] as int,
      monthlyRequired: (json['monthly_required'] as num).toDouble(),
      isOnTrack: json['is_on_track'] as bool,
    );
  }
}