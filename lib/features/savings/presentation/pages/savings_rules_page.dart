import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_rule.dart';
import '../providers/savings_provider.dart';

final savingsRulesProvider = FutureProvider.family<List<SavingsRuleEntity>, int>((ref, goalId) async {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.getRulesByGoal(goalId);
});

class SavingsRulesPage extends ConsumerStatefulWidget {
  final SavingsGoalEntity goal;

  const SavingsRulesPage({super.key, required this.goal});

  @override
  ConsumerState<SavingsRulesPage> createState() => _SavingsRulesPageState();
}

class _SavingsRulesPageState extends ConsumerState<SavingsRulesPage> {
  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(savingsRulesProvider(widget.goal.id!));

    return Scaffold(
      appBar: AppBar(title: const Text('Reglas de Ahorro')),
      body: rulesAsync.when(
        data: (rules) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Reglas Activas para ${widget.goal.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (rules.isEmpty) const Text('No hay reglas configuradas para esta meta.'),
              ...rules.map((r) => ListTile(
                title: Text(r.ruleType == 'round_up' ? 'Redondeo de Gastos' : (r.ruleType == 'fixed_percentage' ? 'Porcentaje de Ingresos' : 'Ahorro Programado')),
                subtitle: Text(r.ruleType == 'fixed_percentage' ? '${r.value}% de cada ingreso' : (r.ruleType == 'scheduled' ? '\$${r.value} mensuales' : 'Redondea tus gastos a la siguiente decena')),
                trailing: Switch(
                  value: r.status == 'active',
                  onChanged: (val) async {
                    final repo = ref.read(savingsRepositoryProvider);
                    await repo.updateRule(r.copyWith(status: val ? 'active' : 'paused'));
                    ref.invalidate(savingsRulesProvider(widget.goal.id!));
                  },
                ),
              )),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Añadir Regla de Redondeo'),
                onTap: () => _addRule('round_up', 0),
              ),
              ListTile(
                leading: const Icon(Icons.percent),
                title: const Text('Añadir Porcentaje (ej. 10%)'),
                onTap: () => _addRule('fixed_percentage', 10),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Añadir Ahorro Programado (ej. \$50)'),
                onTap: () => _addRule('scheduled', 50),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _addRule(String type, double value) async {
    final repo = ref.read(savingsRepositoryProvider);
    await repo.createRule(SavingsRuleEntity(
      goalId: widget.goal.id!,
      ruleType: type,
      value: value,
    ));
    ref.invalidate(savingsRulesProvider(widget.goal.id!));
  }
}
