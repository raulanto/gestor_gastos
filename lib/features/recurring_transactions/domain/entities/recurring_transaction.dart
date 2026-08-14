import '../../../../features/transactions/domain/entities/transaction.dart';

class RecurringTransactionSplit {
  final int? id;
  final int? recurringTransactionId;
  final int categoryId;
  final double amount;

  RecurringTransactionSplit({
    this.id,
    this.recurringTransactionId,
    required this.categoryId,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recurring_transaction_id': recurringTransactionId,
      'category_id': categoryId,
      'amount': amount,
    };
  }

  factory RecurringTransactionSplit.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionSplit(
      id: map['id'],
      recurringTransactionId: map['recurring_transaction_id'],
      categoryId: map['category_id'],
      amount: map['amount'],
    );
  }

  // Convertir a un split normal para cuando se genera la transacción real
  TransactionSplit toTransactionSplit() {
    return TransactionSplit(
      categoryId: categoryId,
      amount: amount,
    );
  }
}

class RecurringTransactionEntity {
  final int? id;
  final double amount;
  final int accountId;
  final int? categoryId;
  final String? name;
  final String? note;
  final String type; // 'expense', 'income'
  final String periodicity; // 'daily', 'weekly', 'biweekly', 'monthly', 'yearly'
  final String nextExecutionDate;
  final String status; // 'active', 'paused'
  final List<RecurringTransactionSplit> splits;

  RecurringTransactionEntity({
    this.id,
    required this.amount,
    required this.accountId,
    this.categoryId,
    this.name,
    this.note,
    this.type = 'expense',
    required this.periodicity,
    required this.nextExecutionDate,
    this.status = 'active',
    this.splits = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'account_id': accountId,
      'category_id': categoryId,
      'name': name,
      'note': note,
      'type': type,
      'periodicity': periodicity,
      'next_execution_date': nextExecutionDate,
      'status': status,
    };
  }

  factory RecurringTransactionEntity.fromMap(Map<String, dynamic> map, {List<RecurringTransactionSplit> splits = const []}) {
    return RecurringTransactionEntity(
      id: map['id'],
      amount: map['amount'],
      accountId: map['account_id'],
      categoryId: map['category_id'],
      name: map['name'],
      note: map['note'],
      type: map['type'],
      periodicity: map['periodicity'],
      nextExecutionDate: map['next_execution_date'],
      status: map['status'],
      splits: splits,
    );
  }

  // Helper para generar la transacción real
  TransactionEntity toTransaction(String executionDate) {
    return TransactionEntity(
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: executionDate,
      note: note,
      type: type,
      splits: splits.map((s) => s.toTransactionSplit()).toList(),
    );
  }
}
