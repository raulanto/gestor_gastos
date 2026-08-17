import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account.dart';
import '../providers/account_provider.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

class AddEditAccountDialog extends ConsumerStatefulWidget {
  final Account? account;

  const AddEditAccountDialog({super.key, this.account});

  @override
  ConsumerState<AddEditAccountDialog> createState() =>
      _AddEditAccountDialogState();
}

class _AddEditAccountDialogState extends ConsumerState<AddEditAccountDialog> {
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late int _selectedIcon;
  late int _selectedColor;

  late final List<IconData> _availableIcons = IconUtils.allIcons;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.account?.balance.toStringAsFixed(2) ?? '',
    );
    _selectedIcon = widget.account?.iconCode ?? _availableIcons.first.codePoint;
    _selectedColor =
        widget.account?.colorCode ?? _availableColors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese un nombre')));
      return;
    }

    final newAccount = Account(
      id: widget.account?.id ?? 0,
      name: name,
      balance: balance,
      iconCode: _selectedIcon,
      colorCode: _selectedColor,
    );

    if (widget.account == null) {
      ref.read(accountsProvider.notifier).addAccount(newAccount);
    } else {
      ref.read(accountsProvider.notifier).updateAccount(newAccount);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.account == null ? 'Nueva Cuenta' : 'Editar Cuenta',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Saldo Inicial',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Icono', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _availableIcons.map((icon) {
                    final isSelected = icon.codePoint == _selectedIcon;
                    final selectedColorObj = Color(_selectedColor);
                    return InkWell(
                      onTap: () => setState(() => _selectedIcon = icon.codePoint),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? selectedColorObj.withValues(alpha: 0.2)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          icon,
                          size: 28,
                          color: isSelected
                              ? selectedColorObj
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Color', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color.toARGB32() == _selectedColor;
                return InkWell(
                  onTap: () =>
                      setState(() => _selectedColor = color.toARGB32()),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Cuenta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
