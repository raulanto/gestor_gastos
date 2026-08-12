import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/loan_payment.dart';
import '../../application/loan_service.dart';
import '../../data/repositories/loan_repository_impl.dart';

final loansProvider = AsyncNotifierProvider<LoansNotifier, List<LoanEntity>>(() {
  return LoansNotifier();
});

class LoansNotifier extends AsyncNotifier<List<LoanEntity>> {
  @override
  Future<List<LoanEntity>> build() async {
    final repo = ref.watch(loanRepositoryProvider);
    return await repo.getLoans();
  }

  Future<void> createLoan(LoanEntity loan) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(loanServiceProvider).createLoan(loan);
      return await ref.read(loanRepositoryProvider).getLoans();
    });
  }

  Future<void> addPayment(LoanPaymentEntity payment, LoanEntity loan) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(loanServiceProvider).addLoanPayment(payment, loan);
      return await ref.read(loanRepositoryProvider).getLoans();
    });
  }
}

final loanPaymentsProvider = FutureProvider.family<List<LoanPaymentEntity>, int>((ref, loanId) async {
  final repo = ref.watch(loanRepositoryProvider);
  return await repo.getLoanPayments(loanId);
});

final loanByIdProvider = Provider.family<LoanEntity?, String>((ref, id) {
  final loans = ref.watch(loansProvider);
  final parsedId = int.tryParse(id);
  if (parsedId == null) return null;
  return loans.maybeWhen(
    data: (list) => list.where((l) => l.id == parsedId).firstOrNull,
    orElse: () => null,
  );
});
