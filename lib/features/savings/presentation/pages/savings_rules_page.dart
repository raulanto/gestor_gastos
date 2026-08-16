import 'package:gestor_gastos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/entities/savings_rule.dart';
import '../providers/savings_provider.dart';

final savingsRulesProvider =
    FutureProvider.family<List<SavingsRuleEntity>, int>((ref, goalId) async {
      final repo = ref.watch(savingsRepositoryProvider);
      return repo.getRulesByGoal(goalId);
    });

class SavingsRulesPage extends ConsumerStatefulWidget {
  final String goalId;

  const SavingsRulesPage({super.key, required this.goalId});

  @override
  ConsumerState<SavingsRulesPage> createState() => _SavingsRulesPageState();
}

class _SavingsRulesPageState extends ConsumerState<SavingsRulesPage> {
  Future<void> _toggleRule(
    SavingsGoalEntity goal,
    SavingsRuleEntity? existingRule,
    String type,
    bool isEnabled,
  ) async {
    final repo = ref.read(savingsRepositoryProvider);
    if (existingRule != null) {
      await repo.updateRule(
        existingRule.copyWith(status: isEnabled ? 'active' : 'paused'),
      );
    } else if (isEnabled) {
      double defaultValue = 0;
      if (type == 'fixed_percentage') defaultValue = 10;
      if (type == 'scheduled') defaultValue = 50;
      if (type == 'round_up') defaultValue = 10;

      await repo.createRule(
        SavingsRuleEntity(
          goalId: goal.id!,
          ruleType: type,
          value: defaultValue,
          status: 'active',
        ),
      );
    }
    ref.invalidate(savingsRulesProvider(goal.id!));
  }

  Future<void> _editRuleValue(
    SavingsGoalEntity goal,
    SavingsRuleEntity rule,
    String title,
  ) async {
    final controller = TextEditingController(
      text: rule.value.toStringAsFixed(
        rule.ruleType == 'fixed_percentage' ? 0 : 2,
      ),
    );
    final newValue = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: rule.ruleType == 'fixed_percentage'
                ? 'Porcentaje (%)'
                : 'Monto (\$)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                Navigator.pop(ctx, val);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (newValue != null) {
      final repo = ref.read(savingsRepositoryProvider);
      await repo.updateRule(rule.copyWith(value: newValue));
      ref.invalidate(savingsRulesProvider(goal.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(savingsGoalByIdProvider(widget.goalId));

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meta no encontrada')),
        body: const Center(child: Text('La meta no existe o fue eliminada')),
      );
    }

    final rulesAsync = ref.watch(savingsRulesProvider(goal.id!));

    return Scaffold(
      appBar: AppBar(title: const Text('Reglas de Ahorro')),
      body: rulesAsync.when(
        data: (rules) {
          final roundUp = rules
              .where((r) => r.ruleType == 'round_up')
              .firstOrNull;
          final percentage = rules
              .where((r) => r.ruleType == 'fixed_percentage')
              .firstOrNull;
          final scheduled = rules
              .where((r) => r.ruleType == 'scheduled')
              .firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Configuración para ${goal.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildRuleTile(
                goal: goal,
                title: 'Redondeo de Gastos',
                subtitle: roundUp != null
                    ? 'Redondea tus gastos a múltiplos de ${CurrencyUtils.formatAmount(roundUp.value, showDecimals: false)}'
                    : 'Desactivado',
                icon: Icons.pie_chart_outline,
                rule: roundUp,
                type: 'round_up',
              ),
              const Divider(),
              _buildRuleTile(
                goal: goal,
                title: 'Porcentaje de Ingresos',
                subtitle: percentage != null
                    ? '${percentage.value.toStringAsFixed(0)}% de cada ingreso'
                    : 'Desactivado',
                icon: Icons.percent,
                rule: percentage,
                type: 'fixed_percentage',
              ),
              const Divider(),
              _buildRuleTile(
                goal: goal,
                title: 'Ahorro Programado',
                subtitle: scheduled != null
                    ? '${CurrencyUtils.formatAmount(scheduled.value)} mensuales'
                    : 'Desactivado',
                icon: Icons.calendar_month,
                rule: scheduled,
                type: 'scheduled',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildRuleTile({
    required SavingsGoalEntity goal,
    required String title,
    required String subtitle,
    required IconData icon,
    required SavingsRuleEntity? rule,
    required String type,
  }) {
    final isActive = rule?.status == 'active';
    final hasValueConfig = true; // Permitir edición para todas las reglas

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.grey.shade200,
        child: Icon(
          icon,
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive && hasValueConfig)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editRuleValue(goal, rule!, 'Editar $title'),
            ),
          Switch(
            value: isActive,
            onChanged: (val) => _toggleRule(goal, rule, type, val),
          ),
        ],
      ),
    );
  }
}
