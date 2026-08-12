import '../../../persons/domain/entities/person.dart';

class LoanEntity {
  final int? id;
  final String? personName; // Made optional to prefer personId
  final int? personId;
  final PersonEntity? person;
  final String type; // e.g., 'cash', 'card'
  final double amount;
  final int accountId;
  final String date;
  final String dueDate;
  final String status; // 'active', 'paid'

  LoanEntity({
    this.id,
    this.personName,
    this.personId,
    this.person,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.date,
    required this.dueDate,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_name': personName,
      'person_id': personId,
      'type': type,
      'amount': amount,
      'account_id': accountId,
      'date': date,
      'due_date': dueDate,
      'status': status,
    };
  }

  factory LoanEntity.fromMap(Map<String, dynamic> map) {
    return LoanEntity(
      id: map['id'],
      personName: map['person_name'] ?? map['person_name_joined'], // Or whatever logic
      personId: map['person_id'],
      type: map['type'],
      amount: map['amount'],
      accountId: map['account_id'],
      date: map['date'],
      dueDate: map['due_date'],
      status: map['status'],
      person: map['person_name_joined'] != null ? PersonEntity(
        id: map['person_id'],
        name: map['person_name_joined'],
        phone: map['person_phone'],
        photoPath: map['person_photo'],
      ) : null,
    );
  }

  LoanEntity copyWith({
    int? id,
    String? personName,
    int? personId,
    PersonEntity? person,
    String? type,
    double? amount,
    int? accountId,
    String? date,
    String? dueDate,
    String? status,
  }) {
    return LoanEntity(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      personId: personId ?? this.personId,
      person: person ?? this.person,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}
