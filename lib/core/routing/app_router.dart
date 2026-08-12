import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/domain/entities/account.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/accounts/presentation/pages/account_details_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_page.dart';
import '../../features/recurring_transactions/domain/entities/recurring_transaction.dart';
import '../../features/recurring_transactions/presentation/pages/add_recurring_transaction_page.dart';
import '../../features/recurring_transactions/presentation/pages/recurring_transactions_page.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/pin_provider.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/pin_login_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/savings/domain/entities/savings_goal.dart';
import '../../features/savings/presentation/pages/add_savings_goal_page.dart';
import '../../features/savings/presentation/pages/savings_completed_page.dart';
import '../../features/savings/presentation/pages/savings_goal_details_page.dart';
import '../../features/savings/presentation/pages/savings_rules_page.dart';
import '../../features/savings/presentation/pages/savings_page.dart';
import '../../features/budgets/presentation/pages/add_budget_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/home/presentation/widgets/transactions_view.dart';
import '../../features/loans/presentation/pages/loans_page.dart';
import '../../features/loans/presentation/pages/add_loan_page.dart';
import '../../features/loans/presentation/pages/loan_details_page.dart';
import '../../features/loans/domain/entities/loan.dart';
import '../../features/persons/domain/entities/person.dart';
import '../../features/persons/presentation/pages/add_edit_person_page.dart';
import '../../features/persons/presentation/pages/persons_catalog_page.dart';
import '../presentation/layouts/main_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorTransactionsKey = GlobalKey<NavigatorState>(debugLabel: 'shellTransactions');
final GlobalKey<NavigatorState> _shellNavigatorRecurringKey = GlobalKey<NavigatorState>(debugLabel: 'shellRecurring');
final GlobalKey<NavigatorState> _shellNavigatorSavingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSavings');
final GlobalKey<NavigatorState> _shellNavigatorBudgetsKey = GlobalKey<NavigatorState>(debugLabel: 'shellBudgets');
final GlobalKey<NavigatorState> _shellNavigatorLoansKey = GlobalKey<NavigatorState>(debugLabel: 'shellLoans');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final pinState = ref.watch(pinProvider);
  final sessionState = ref.watch(sessionProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading || pinState.isLoading) return null;

      final isAuth = authState.value != null;
      final hasPin = pinState.value != null;
      final isUnlocked = sessionState;

      final isGoingToAuthPages = state.matchedLocation == '/' || state.matchedLocation == '/login';
      final isGoingToPinSetup = state.matchedLocation == '/pin_setup';
      final isGoingToPinLogin = state.matchedLocation == '/pin_login';

      if (!isAuth && !isGoingToAuthPages) {
        return '/';
      }

      if (isAuth) {
        if (!hasPin && !isGoingToPinSetup) {
          return '/pin_setup';
        }
        if (hasPin && !isUnlocked && !isGoingToPinLogin) {
          return '/pin_login';
        }
        
        if (hasPin && isUnlocked && (isGoingToAuthPages || isGoingToPinSetup || isGoingToPinLogin)) {
          return '/transactions';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/pin_setup',
        name: 'pin_setup',
        builder: (context, state) => const PinSetupPage(),
      ),
      GoRoute(
        path: '/pin_login',
        name: 'pin_login',
        builder: (context, state) => const PinLoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTransactionsKey,
            routes: [
              GoRoute(
                path: '/transactions',
                name: 'transactions',
                builder: (context, state) => const TransactionsView(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorRecurringKey,
            routes: [
              GoRoute(
                path: '/recurring',
                name: 'recurring',
                builder: (context, state) => const RecurringTransactionsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSavingsKey,
            routes: [
              GoRoute(
                path: '/savings',
                name: 'savings',
                builder: (context, state) => const SavingsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBudgetsKey,
            routes: [
              GoRoute(
                path: '/budgets',
                name: 'budgets',
                builder: (context, state) => const BudgetsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorLoansKey,
            routes: [
              GoRoute(
                path: '/loans',
                name: 'loans',
                builder: (context, state) => const LoansPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/accounts',
        name: 'accounts',
        builder: (context, state) => const AccountsPage(),
      ),
      GoRoute(
        path: '/account_details',
        name: 'account_details',
        builder: (context, state) {
          final account = state.extra as Account;
          return AccountDetailsPage(account: account);
        },
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/add_transaction',
        name: 'add_transaction',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'];
          return AddTransactionPage(initialType: type);
        },
      ),
      GoRoute(
        path: '/add_recurring_transaction',
        name: 'add_recurring_transaction',
        builder: (context, state) {
          final tx = state.extra as RecurringTransactionEntity?;
          return AddRecurringTransactionPage(transactionToEdit: tx);
        },
      ),
      GoRoute(
        path: '/edit_transaction',
        name: 'edit_transaction',
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity?;
          return AddTransactionPage(existingTransaction: transaction);
        },
      ),
      GoRoute(
        path: '/transaction_details',
        name: 'transaction_details',
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity;
          return TransactionDetailsPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: '/add_savings_goal',
        name: 'add_savings_goal',
        builder: (context, state) => const AddSavingsGoalPage(),
      ),
      GoRoute(
        path: '/savings_goal_details',
        name: 'savings_goal_details',
        builder: (context, state) {
          final goal = state.extra as SavingsGoalEntity;
          return SavingsGoalDetailsPage(goal: goal);
        },
      ),
      GoRoute(
        path: '/savings_rules',
        name: 'savings_rules',
        builder: (context, state) {
          final goal = state.extra as SavingsGoalEntity;
          return SavingsRulesPage(goal: goal);
        },
      ),
      GoRoute(
        path: '/savings_completed',
        name: 'savings_completed',
        builder: (context, state) => const SavingsCompletedPage(),
      ),
      GoRoute(
        path: '/add_budget',
        name: 'add_budget',
        builder: (context, state) {
          final monthYear = state.extra as String;
          return AddBudgetPage(monthYear: monthYear);
        },
      ),
      GoRoute(
        path: '/add_loan',
        name: 'add_loan',
        builder: (context, state) => const AddLoanPage(),
      ),
      GoRoute(
        path: '/loan_details',
        name: 'loan_details',
        builder: (context, state) {
          final loan = state.extra as LoanEntity;
          return LoanDetailsPage(loan: loan);
        },
      ),
      GoRoute(
        path: '/persons',
        name: 'persons',
        builder: (context, state) {
          final select = state.uri.queryParameters['select'] == 'true';
          return PersonsCatalogPage(isSelectionMode: select);
        },
      ),
      GoRoute(
        path: '/add_person',
        name: 'add_person',
        builder: (context, state) => const AddEditPersonPage(),
      ),
      GoRoute(
        path: '/edit_person',
        name: 'edit_person',
        builder: (context, state) {
          final person = state.extra as PersonEntity;
          return AddEditPersonPage(personToEdit: person);
        },
      ),
    ],
  );
});
