class LoanPaymentEntity {
  final int? id;
  final int loanId;
  final double amount;
  final String date;

  LoanPaymentEntity({
    this.id,
    required this.loanId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'loan_id': loanId, 'amount': amount, 'date': date};
  }

  factory LoanPaymentEntity.fromMap(Map<String, dynamic> map) {
    return LoanPaymentEntity(
      id: map['id'],
      loanId: map['loan_id'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
