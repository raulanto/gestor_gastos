import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../transactions/domain/entities/transaction.dart';
import '../../transactions/presentation/providers/transaction_provider.dart';
import '../domain/entities/loan.dart';
import '../domain/entities/loan_payment.dart';
import '../domain/repositories/loan_repository.dart';
import '../data/repositories/loan_repository_impl.dart';

final loanServiceProvider = Provider<LoanService>((ref) {
  final loanRepo = ref.watch(loanRepositoryProvider);
  final txNotifier = ref.read(transactionsProvider.notifier);
  final db = ref.watch(appDatabaseProvider);
  return LoanService(loanRepo, txNotifier, db);
});

class LoanService {
  final LoanRepository _loanRepository;
  final TransactionNotifier _transactionNotifier;
  final AppDatabase _db;

  LoanService(this._loanRepository, this._transactionNotifier, this._db);

  Future<int?> _getPrestamosCategoryId() async {
    final db = await _db.database;
    final res = await db.query('categories', where: 'name = ?', whereArgs: ['Préstamos']);
    if (res.isNotEmpty) {
      return res.first['id'] as int;
    }
    return null;
  }

  Future<void> createLoan(LoanEntity loan) async {
    // 1. Save loan
    final loanId = await _loanRepository.createLoan(loan);

    // 2. Register expense transaction
    final catId = await _getPrestamosCategoryId();
    final tx = TransactionEntity(
      accountId: loan.accountId,
      categoryId: catId,
      amount: loan.amount,
      date: loan.date,
      type: 'expense',
      note: 'Préstamo a ${loan.personName}',
      splits: [],
    );

    // Assuming transaction service has addTransaction
    await _transactionNotifier.addTransaction(tx);
  }

  Future<void> addLoanPayment(LoanPaymentEntity payment, LoanEntity loan) async {
    // 1. Save payment
    await _loanRepository.addLoanPayment(payment);

    // 2. Update loan status if fully paid? 
    // We calculate total paid
    final payments = await _loanRepository.getLoanPayments(loan.id!);
    final totalPaid = payments.fold<double>(0.0, (sum, p) => sum + p.amount);
    
    if (totalPaid >= loan.amount && loan.status != 'paid') {
      await _loanRepository.updateLoan(loan.copyWith(status: 'paid'));
    }

    // 3. Register income transaction
    final catId = await _getPrestamosCategoryId();
    final tx = TransactionEntity(
      accountId: loan.accountId, // It returns to the same account
      categoryId: catId,
      amount: payment.amount,
      date: payment.date,
      type: 'income',
      note: 'Abono de préstamo de ${loan.personName}',
      splits: [],
    );

    await _transactionNotifier.addTransaction(tx);
  }
}
