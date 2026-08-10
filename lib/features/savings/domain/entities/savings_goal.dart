class SavingsGoalEntity {
  final int? id;
  final String name;
  final double targetAmount;
  final String? deadlineDate;
  final int iconCode;
  final int colorCode;
  final String status; // 'active', 'completed', 'archived'

  SavingsGoalEntity({
    this.id,
    required this.name,
    required this.targetAmount,
    this.deadlineDate,
    required this.iconCode,
    required this.colorCode,
    this.status = 'active',
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
  }) {
    return SavingsGoalEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      iconCode: iconCode ?? this.iconCode,
      colorCode: colorCode ?? this.colorCode,
      status: status ?? this.status,
    );
  }
}
