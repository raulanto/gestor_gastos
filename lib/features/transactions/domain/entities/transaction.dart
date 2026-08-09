class TransactionSplit {
  final int? id;
  final int? transactionId;
  final int categoryId;
  final double amount;

  TransactionSplit({
    this.id,
    this.transactionId,
    required this.categoryId,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'category_id': categoryId,
      'amount': amount,
    };
  }

  factory TransactionSplit.fromMap(Map<String, dynamic> map) {
    return TransactionSplit(
      id: map['id'],
      transactionId: map['transaction_id'],
      categoryId: map['category_id'],
      amount: map['amount'],
    );
  }
}

class TransactionEntity {
  final int? id;
  final int accountId;
  final int? categoryId; // Puede ser nulo si tiene múltiples splits
  final double amount;
  final String date;
  final String? note;
  final String? receiptImagePath;
  final String type; // 'expense', 'income', 'transfer'
  final List<TransactionSplit> splits;

  TransactionEntity({
    this.id,
    required this.accountId,
    this.categoryId,
    required this.amount,
    required this.date,
    this.note,
    this.receiptImagePath,
    this.type = 'expense',
    this.splits = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'amount': amount,
      'date': date,
      'note': note,
      'receipt_path': receiptImagePath,
      'type': type,
    };
  }

  factory TransactionEntity.fromMap(Map<String, dynamic> map, {List<TransactionSplit> splits = const []}) {
    return TransactionEntity(
      id: map['id'],
      accountId: map['account_id'],
      categoryId: splits.isNotEmpty ? splits.first.categoryId : null,
      amount: map['amount'],
      date: map['date'],
      note: map['note'],
      receiptImagePath: map['receipt_path'],
      type: map['type'] ?? 'expense',
      splits: splits,
    );
  }
}
