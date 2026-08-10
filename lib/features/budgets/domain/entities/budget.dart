class BudgetEntity {
  final int? id;
  final int? categoryId;
  final int? savingsGoalId;
  final double amount;
  final String monthYear; // Formato YYYY-MM

  BudgetEntity({
    this.id,
    this.categoryId,
    this.savingsGoalId,
    required this.amount,
    required this.monthYear,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'category_id': categoryId,
      'savings_goal_id': savingsGoalId,
      'amount': amount,
      'month_year': monthYear,
    };
  }

  factory BudgetEntity.fromMap(Map<String, dynamic> map) {
    return BudgetEntity(
      id: map['id'],
      categoryId: map['category_id'],
      savingsGoalId: map['savings_goal_id'],
      amount: map['amount'],
      monthYear: map['month_year'],
    );
  }

  BudgetEntity copyWith({
    int? id,
    int? categoryId,
    int? savingsGoalId,
    double? amount,
    String? monthYear,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      amount: amount ?? this.amount,
      monthYear: monthYear ?? this.monthYear,
    );
  }
}
