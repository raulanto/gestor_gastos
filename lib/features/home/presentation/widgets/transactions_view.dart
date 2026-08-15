import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../providers/home_summary_provider.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../../core/theme/theme_provider.dart';

import 'home_header.dart';
import 'period_selector.dart';
import 'kpi_cards.dart';
import 'home_chart.dart';
import 'home_category_chart.dart';
import 'chart_type_selector.dart';
import 'transaction_list.dart';

class TransactionsView extends ConsumerStatefulWidget {
  const TransactionsView({super.key});

  @override
  ConsumerState<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends ConsumerState<TransactionsView> {
  int _chartType = 0; // 0 = Flujo, 1 = Categorías
  bool _isBalanceMinimized = false;
  bool _showCharts = false;

  int? _selectedAccountId;

  void _toggleBalanceMinimized() {
    setState(() {
      _isBalanceMinimized = !_isBalanceMinimized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(homeSummaryProvider);
    final accountsState = ref.watch(accountsProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: summaryState.when(
        data: (summary) {
          // Grouping for the transaction list
          Map<String, List<TransactionEntity>> groupedTransactions = {};
          final now = DateTime.now();
          for (var t in summary.transactions) {
            // Filtrar aportaciones/retiros de metas de ahorro (no tienen categoría ni splits)
            if (t.categoryId == null && t.splits.isEmpty) {
              continue;
            }

            if (_selectedAccountId != null &&
                _selectedAccountId != -1 &&
                t.accountId != _selectedAccountId) {
              continue;
            }

            final date = DateTime.parse(t.date);
            final diff = DateTime(
              now.year,
              now.month,
              now.day,
            ).difference(DateTime(date.year, date.month, date.day)).inDays;

            String key;
            if (diff == 0) {
              key = 'HOY';
            } else if (diff == 1) {
              key = 'AYER';
            } else {
              key = DateFormat('dd MMM').format(date).toUpperCase();
            }

            if (!groupedTransactions.containsKey(key)) {
              groupedTransactions[key] = [];
            }
            groupedTransactions[key]!.add(t);
          }

          return Stack(
            children: [
              // Imagen de fondo con degradado (expande al minimizar)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                left: 0,
                right: 0,
                height: _isBalanceMinimized
                    ? MediaQuery.of(context).size.height
                    : 350,
                child: AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ref.watch(appBackgroundProvider)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withValues(
                            alpha: _isBalanceMinimized ? 0.2 : 0.4,
                          ),
                          theme.colorScheme.primary.withValues(
                            alpha: _isBalanceMinimized ? 0.6 : 1.0,
                          ),
                        ],
                      ),
                    ),
                    ),
                  ),
                ),
              // Restaurar al deslizar hacia arriba
              if (_isBalanceMinimized)
                Positioned.fill(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy < -10) {
                        setState(() {
                          _isBalanceMinimized = false;
                        });
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! > 0) {
                          ref.read(appBackgroundProvider.notifier).previousBackground();
                        } else if (details.primaryVelocity! < 0) {
                          ref.read(appBackgroundProvider.notifier).nextBackground();
                        }
                      }
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              // Panel Inferior Animado
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                top: _isBalanceMinimized
                    ? MediaQuery.of(context).size.height
                    : 240,
                left: 0,
                right: 0,
                bottom: 0,
                child: Material(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              KpiCards(
                                totalIncome: summary.totalIncome,
                                totalExpense: summary.totalExpense,
                              ),
                              const SizedBox(height: 32),
                              InkWell(
                                onTap: () => setState(() => _showCharts = !_showCharts),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Análisis',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Icon(
                                        _showCharts ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                alignment: Alignment.topCenter,
                                child: _showCharts 
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: ChartTypeSelector(
                                            chartType: _chartType,
                                            onChanged: (val) {
                                              setState(() {
                                                _chartType = val;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 200,
                                          child: _chartType == 0
                                              ? HomeChart(chartData: summary.chartData)
                                              : HomeCategoryChart(
                                                  categoryData: summary.categoryExpenses,
                                                ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => context.push(
                                        '/add_transaction?type=income',
                                      ),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Ingreso'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: theme
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.15),
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => context.push(
                                        '/add_transaction?type=expense',
                                      ),
                                      icon: const Icon(Icons.call_made),
                                      label: const Text('Gasto'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: theme
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.15),
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Historial',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      // Filtro de Cuenta
                                      PopupMenuButton<int>(
                                        icon: Icon(
                                          Icons.account_balance_wallet,
                                          color:
                                              _selectedAccountId != null &&
                                                  _selectedAccountId != -1
                                              ? theme.colorScheme.primary
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                        tooltip: 'Filtrar por cuenta',
                                        onSelected: (val) => setState(
                                          () => _selectedAccountId = val,
                                        ),
                                        itemBuilder: (context) {
                                          final items = <PopupMenuEntry<int>>[
                                            const PopupMenuItem(
                                              value: -1,
                                              child: Text('Todas las cuentas'),
                                            ),
                                          ];
                                          if (accountsState.value != null) {
                                            for (var account
                                                in accountsState.value!) {
                                              items.add(
                                                PopupMenuItem(
                                                  value: account.id,
                                                  child: Text(account.name),
                                                ),
                                              );
                                            }
                                          }
                                          return items;
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      TransactionList(groupedTransactions: groupedTransactions),
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: 100),
                      ),
                    ],
                  ),
                ),
              ),
              // Contenido principal (Header superior)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                top: _isBalanceMinimized
                    ? MediaQuery.of(context).size.height * 0.35
                    : 0,
                left: 0,
                right: 0,
                child: HomeHeader(
                  totalBalance: summary.totalBalance,
                  totalIncome: summary.totalIncome,
                  totalExpense: summary.totalExpense,
                  isMinimized: _isBalanceMinimized,
                  onToggleMinimize: _toggleBalanceMinimized,
                ),
              ),
              // Selector de periodo (se oculta al minimizar)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _isBalanceMinimized ? -100 : 180,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isBalanceMinimized ? 0.0 : 1.0,
                  child: const PeriodSelector(),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.onPrimary),
        ),
        error: (e, st) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
