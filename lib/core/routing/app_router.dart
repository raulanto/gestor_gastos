import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/transaction_details_page.dart';
import '../../features/recurring_transactions/presentation/pages/add_recurring_transaction_page.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/welcome_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Si la carga de autenticación está en progreso, esperar.
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isGoingToAuthPages = state.matchedLocation == '/' || state.matchedLocation == '/login';

      // Si el usuario está autenticado y está en páginas de inicio/login, mandarlo a /home
      if (isAuth && isGoingToAuthPages) {
        return '/home';
      }

      // Si NO está autenticado e intenta ir a cualquier lugar que no sea inicio/login, mandarlo a /
      if (!isAuth && !isGoingToAuthPages) {
        return '/';
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
        builder: (context, state) => const AddTransactionPage(),
      ),
      GoRoute(
        path: '/add_recurring_transaction',
        name: 'add_recurring_transaction',
        builder: (context, state) => const AddRecurringTransactionPage(),
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
    ],
  );
});
