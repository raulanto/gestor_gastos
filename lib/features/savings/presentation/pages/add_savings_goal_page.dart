import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_provider.dart';

class AddSavingsGoalPage extends ConsumerStatefulWidget {
  const AddSavingsGoalPage({super.key});

  @override
  ConsumerState<AddSavingsGoalPage> createState() => _AddSavingsGoalPageState();
}

class _AddSavingsGoalPageState extends ConsumerState<AddSavingsGoalPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _targetAmount = 0.0;
  DateTime? _deadline;

  bool _isProtected = false;
  bool _deductFromBalance = true;
  int _priority = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),

              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ref.watch(appBackgroundProvider)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.4),
                      theme.colorScheme.primary.withValues(alpha: 1.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nueva Meta de Ahorro',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(24.0),
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la Meta (ej. Viaje)',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requerido' : null,
                            onSaved: (v) => _name = v!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Monto Objetivo',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) =>
                                v == null || double.tryParse(v) == null
                                ? 'Monto inválido'
                                : null,
                            onSaved: (v) => _targetAmount = double.parse(v!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Prioridad (Reglas Automáticas)',
                              helperText:
                                  'Menor número = mayor prioridad (ej. 1 se procesa antes que 2)',
                              prefixIcon: Icon(Icons.low_priority),
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: '0',
                            onSaved: (v) =>
                                _priority = int.tryParse(v ?? '0') ?? 0,
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('Proteger Meta'),
                            subtitle: const Text(
                              'Pedir confirmación extra antes de retirar fondos',
                            ),
                            value: _isProtected,
                            onChanged: (val) =>
                                setState(() => _isProtected = val),
                          ),
                          SwitchListTile(
                            title: const Text('Vincular con Saldo Real'),
                            subtitle: const Text(
                              'Restar los ahorros del saldo disponible de tu cuenta',
                            ),
                            value: _deductFromBalance,
                            onChanged: (val) =>
                                setState(() => _deductFromBalance = val),
                          ),
                          const SizedBox(height: 32),
                          FilledButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final newGoal = SavingsGoalEntity(
                                  name: _name,
                                  targetAmount: _targetAmount,
                                  deadlineDate: _deadline?.toIso8601String(),
                                  iconCode: Icons.savings.codePoint,
                                  colorCode: Colors.blue.toARGB32(),
                                  isProtected: _isProtected,
                                  priority: _priority,
                                  deductFromBalance: _deductFromBalance,
                                );
                                ref
                                    .read(savingsGoalsProvider.notifier)
                                    .addGoal(newGoal);
                                context.pop();
                              }
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Guardar Meta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
