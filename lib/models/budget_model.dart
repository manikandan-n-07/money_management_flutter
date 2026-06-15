// lib/models/budget_model.dart
// Hive model for monthly budgets

import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 5)
class BudgetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double monthlyBudget;

  @HiveField(2)
  int month; // 1-12

  @HiveField(3)
  int year;

  @HiveField(4)
  double savingsGoal;

  @HiveField(5)
  DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.monthlyBudget,
    required this.month,
    required this.year,
    this.savingsGoal = 0.0,
    required this.createdAt,
  });

  BudgetModel copyWith({
    String? id,
    double? monthlyBudget,
    int? month,
    int? year,
    double? savingsGoal,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      month: month ?? this.month,
      year: year ?? this.year,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'monthlyBudget': monthlyBudget,
        'month': month,
        'year': year,
        'savingsGoal': savingsGoal,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json['id'] as String,
        monthlyBudget: (json['monthlyBudget'] as num).toDouble(),
        month: json['month'] as int,
        year: json['year'] as int,
        savingsGoal: (json['savingsGoal'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
