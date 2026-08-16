class SavingsRuleEntity {
  final int? id;
  final int goalId;
  final String ruleType; // 'round_up', 'fixed_percentage', 'scheduled'
  final double
  value; // Can be a fixed amount, percentage, or unused (for round_up)
  final String status; // 'active', 'paused'

  SavingsRuleEntity({
    this.id,
    required this.goalId,
    required this.ruleType,
    required this.value,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'rule_type': ruleType,
      'value': value,
      'status': status,
    };
  }

  factory SavingsRuleEntity.fromMap(Map<String, dynamic> map) {
    return SavingsRuleEntity(
      id: map['id'],
      goalId: map['goal_id'],
      ruleType: map['rule_type'],
      value: map['value'],
      status: map['status'] ?? 'active',
    );
  }

  SavingsRuleEntity copyWith({
    int? id,
    int? goalId,
    String? ruleType,
    double? value,
    String? status,
  }) {
    return SavingsRuleEntity(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      ruleType: ruleType ?? this.ruleType,
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }
}
