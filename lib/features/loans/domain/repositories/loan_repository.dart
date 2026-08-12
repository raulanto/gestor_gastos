import '../entities/loan.dart';
import '../entities/loan_payment.dart';

abstract class LoanRepository {
  Future<List<LoanEntity>> getLoans();
  Future<LoanEntity?> getLoanById(int id);
  Future<int> createLoan(LoanEntity loan);
  Future<void> updateLoan(LoanEntity loan);
  Future<void> deleteLoan(int id);
  
  Future<List<LoanPaymentEntity>> getLoanPayments(int loanId);
  Future<int> addLoanPayment(LoanPaymentEntity payment);
  Future<void> deleteLoanPayment(int paymentId);
}
