class SavingsTransactionEntity {
  final int? id;
  final int goalId;
  final int accountId;
  final double amount;
  final String date;
  final String type; // 'deposit', 'withdrawal'
  final String? reason;

  SavingsTransactionEntity({
    this.id,
    required this.goalId,
    required this.accountId,
    required this.amount,
    required this.date,
    required this.type,
    this.reason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'account_id': accountId,
      'amount': amount,
      'date': date,
      'type': type,
      'reason': reason,
    };
  }

  factory SavingsTransactionEntity.fromMap(Map<String, dynamic> map) {
    return SavingsTransactionEntity(
      id: map['id'],
      goalId: map['goal_id'],
      accountId: map['account_id'],
      amount: map['amount'],
      date: map['date'],
      type: map['type'],
      reason: map['reason'],
    );
  }
}
