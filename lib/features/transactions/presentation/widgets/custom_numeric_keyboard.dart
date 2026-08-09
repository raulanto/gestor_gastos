import 'package:flutter/material.dart';

class CustomNumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CustomNumericKeyboard({
    super.key,
    required this.onKeyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        padding: const EdgeInsets.all(8),
        children: [
          _buildKey('7', context),
          _buildKey('8', context),
          _buildKey('9', context),
          _buildKey('⌫', context, icon: Icons.backspace_outlined),
          _buildKey('4', context),
          _buildKey('5', context),
          _buildKey('6', context),
          _buildKey('+', context, color: Theme.of(context).colorScheme.secondary),
          _buildKey('1', context),
          _buildKey('2', context),
          _buildKey('3', context),
          _buildKey('-', context, color: Theme.of(context).colorScheme.secondary),
          _buildKey('.', context),
          _buildKey('0', context),
          _buildKey('=', context, color: Theme.of(context).colorScheme.secondary),
          _buildKey('✓', context, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildKey(String value, BuildContext context, {IconData? icon, Color? color}) {
    final theme = Theme.of(context);
    final isAction = icon != null || value == '+' || value == '-' || value == '=' || value == '✓';
    
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: isAction ? (color ?? theme.colorScheme.surfaceContainerHighest) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onKeyPressed(value),
          child: Center(
            child: icon != null
                ? Icon(icon, size: 28, color: isAction ? (color == theme.colorScheme.primary ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface) : theme.colorScheme.onSurface)
                : Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: color != null ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      fontWeight: isAction ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
