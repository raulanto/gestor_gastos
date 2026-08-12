import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../../domain/repositories/loan_repository.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LoanRepositoryImpl(db);
});

class LoanRepositoryImpl implements LoanRepository {
  final AppDatabase _appDatabase;

  LoanRepositoryImpl(this._appDatabase);

  @override
  Future<List<LoanEntity>> getLoans() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        l.*, 
        p.name as person_name_joined, 
        p.phone as person_phone, 
        p.photo_path as person_photo 
      FROM loans l
      LEFT JOIN persons p ON l.person_id = p.id
    ''');
    return List.generate(maps.length, (i) {
      return LoanEntity.fromMap(maps[i]);
    });
  }

  @override
  Future<LoanEntity?> getLoanById(int id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        l.*, 
        p.name as person_name_joined, 
        p.phone as person_phone, 
        p.photo_path as person_photo 
      FROM loans l
      LEFT JOIN persons p ON l.person_id = p.id
      WHERE l.id = ?
    ''', [id]);
    if (maps.isNotEmpty) {
      return LoanEntity.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> createLoan(LoanEntity loan) async {
    final db = await _appDatabase.database;
    return await db.insert('loans', loan.toMap());
  }

  @override
  Future<void> updateLoan(LoanEntity loan) async {
    final db = await _appDatabase.database;
    await db.update(
      'loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  @override
  Future<void> deleteLoan(int id) async {
    final db = await _appDatabase.database;
    await db.delete(
      'loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<LoanPaymentEntity>> getLoanPayments(int loanId) async {
    final db = await _appDatabase.database;
    final maps = await db.query(
      'loan_payments',
      where: 'loan_id = ?',
      whereArgs: [loanId],
    );
    return List.generate(maps.length, (i) {
      return LoanPaymentEntity.fromMap(maps[i]);
    });
  }

  @override
  Future<int> addLoanPayment(LoanPaymentEntity payment) async {
    final db = await _appDatabase.database;
    return await db.insert('loan_payments', payment.toMap());
  }

  @override
  Future<void> deleteLoanPayment(int paymentId) async {
    final db = await _appDatabase.database;
    await db.delete(
      'loan_payments',
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }
}
