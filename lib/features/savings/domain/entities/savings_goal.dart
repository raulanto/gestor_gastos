class SavingsGoalEntity {
  final int? id;
  final String name;
  final double targetAmount;
  final String? deadlineDate;
  final int iconCode;
  final int colorCode;
  final String status; // 'active', 'completed', 'archived'
  final bool isProtected;
  final int priority;
  final bool deductFromBalance;

  SavingsGoalEntity({
    this.id,
    required this.name,
    required this.targetAmount,
    this.deadlineDate,
    required this.iconCode,
    required this.colorCode,
    this.status = 'active',
    this.isProtected = false,
    this.priority = 0,
    this.deductFromBalance = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'deadline_date': deadlineDate,
      'icon_code': iconCode,
      'color_code': colorCode,
      'status': status,
      'is_protected': isProtected ? 1 : 0,
      'priority': priority,
      'deduct_from_balance': deductFromBalance ? 1 : 0,
    };
  }

  factory SavingsGoalEntity.fromMap(Map<String, dynamic> map) {
    return SavingsGoalEntity(
      id: map['id'],
      name: map['name'],
      targetAmount: map['target_amount'],
      deadlineDate: map['deadline_date'],
      iconCode: map['icon_code'],
      colorCode: map['color_code'],
      status: map['status'] ?? 'active',
      isProtected: (map['is_protected'] ?? 0) == 1,
      priority: map['priority'] ?? 0,
      deductFromBalance: (map['deduct_from_balance'] ?? 1) == 1,
    );
  }

  SavingsGoalEntity copyWith({
    int? id,
    String? name,
    double? targetAmount,
    String? deadlineDate,
    int? iconCode,
    int? colorCode,
    String? status,
    bool? isProtected,
    int? priority,
    bool? deductFromBalance,
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      iconCode: iconCode ?? this.iconCode,
      colorCode: colorCode ?? this.colorCode,
      status: status ?? this.status,
      isProtected: isProtected ?? this.isProtected,
      priority: priority ?? this.priority,
      deductFromBalance: deductFromBalance ?? this.deductFromBalance,
    );
  }
}
