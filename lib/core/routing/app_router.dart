import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_page.dart';
import '../../features/recurring_transactions/domain/entities/recurring_transaction.dart';
import '../../features/recurring_transactions/presentation/pages/add_recurring_transaction_page.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/pin_provider.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/pin_setup_page.dart';
import '../../features/auth/presentation/pages/pin_login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';
import '../../features/savings/domain/entities/savings_goal.dart';
import '../../features/savings/presentation/pages/add_savings_goal_page.dart';
import '../../features/savings/presentation/pages/savings_completed_page.dart';
import '../../features/savings/presentation/pages/savings_goal_details_page.dart';
import '../../features/savings/presentation/pages/savings_rules_page.dart';
import '../../features/budgets/presentation/pages/add_budget_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final pinState = ref.watch(pinProvider);
  final sessionState = ref.watch(sessionProvider);

  return GoRouter(
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
          return '/home';
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
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/accounts',
        name: 'accounts',
        builder: (context, state) => const AccountsPage(),
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
    ],
  );
});
