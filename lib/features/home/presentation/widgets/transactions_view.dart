import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../providers/home_summary_provider.dart';
import '../providers/period_view_provider.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../../core/providers/date_filter_provider.dart';
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
  static const int _pageSize = 30;

  int _chartType = 0; // 0 = Flujo, 1 = Categorías
  bool _isBalanceMinimized = false;
  bool _showCharts = false;

  int? _selectedAccountId;
  int _visibleCount = _pageSize;
  bool _hasMore = false;

  late final ScrollController _scrollController;

  // Caché para evitar recalcular filtros y agrupaciones en cada frame de animación
  List<TransactionEntity>? _cachedTransactions;
  int? _cachedSelectedAccountId;
  int? _cachedVisibleCount;
  Map<String, List<TransactionEntity>> _cachedGroupedTransactions = {};
  List<TransactionEntity> _cachedVisibleTxs = [];
  bool _cachedHasMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      if (_hasMore) {
        setState(() {
          _visibleCount += _pageSize;
        });
      }
    }
  }

  void _resetPagination() {
    _visibleCount = _pageSize;
  }

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

    // Reiniciar la paginación cuando cambia el período mostrado, para no
    // arrastrar un tope de visibilidad calculado sobre otro conjunto de datos.
    ref.listen(selectedMonthProvider, (prev, next) {
      if (prev != next) setState(_resetPagination);
    });
    ref.listen(periodViewProvider, (prev, next) {
      if (prev != next) setState(_resetPagination);
    });

    return SafeArea(
      bottom: false,
      child: summaryState.when(
        data: (summary) {
          // Filtrar por cuenta y descartar aportaciones/retiros de metas de
          // ahorro (no tienen categoría ni splits) antes de paginar.
          if (_cachedTransactions != summary.transactions ||
              _cachedSelectedAccountId != _selectedAccountId ||
              _cachedVisibleCount != _visibleCount) {
            final filteredTxs = summary.transactions.where((t) {
              if (t.categoryId == null && t.splits.isEmpty) return false;
              if (_selectedAccountId != null &&
                  _selectedAccountId != -1 &&
                  t.accountId != _selectedAccountId) {
                return false;
              }
              return true;
            }).toList();

            _cachedHasMore = _visibleCount < filteredTxs.length;
            _cachedVisibleTxs = filteredTxs.take(_visibleCount).toList();

            // Agrupación por fecha, cargada de forma incremental al desplazar.
            final Map<String, List<TransactionEntity>> groupedTransactions = {};
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            for (var t in _cachedVisibleTxs) {
              final date = DateTime.parse(t.date);
              final diff = today
                  .difference(DateTime(date.year, date.month, date.day))
                  .inDays;

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

            _cachedTransactions = summary.transactions;
            _cachedSelectedAccountId = _selectedAccountId;
            _cachedVisibleCount = _visibleCount;
            _cachedGroupedTransactions = groupedTransactions;
          }

          _hasMore = _cachedHasMore;
          final hasMore = _cachedHasMore;
          final groupedTransactions = _cachedGroupedTransactions;

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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: Container(
                    key: ValueKey(ref.watch(appBackgroundProvider)),
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
                          ref
                              .read(appBackgroundProvider.notifier)
                              .previousBackground();
                        } else if (details.primaryVelocity! < 0) {
                          ref
                              .read(appBackgroundProvider.notifier)
                              .nextBackground();
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
                    controller: _scrollController,
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
                                onTap: () =>
                                    setState(() => _showCharts = !_showCharts),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Análisis',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Icon(
                                        _showCharts
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 16),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
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
                                                ? HomeChart(
                                                    chartData:
                                                        summary.chartData,
                                                  )
                                                : HomeCategoryChart(
                                                    categoryData: summary
                                                        .categoryExpenses,
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
                                        onSelected: (val) => setState(() {
                                          _selectedAccountId = val;
                                          _resetPagination();
                                        }),
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
                      if (hasMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
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
