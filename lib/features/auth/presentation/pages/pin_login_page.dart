import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pin_provider.dart';
import '../providers/session_provider.dart';

class PinLoginPage extends ConsumerStatefulWidget {
  const PinLoginPage({super.key});

  @override
  ConsumerState<PinLoginPage> createState() => _PinLoginPageState();
}

class _PinLoginPageState extends ConsumerState<PinLoginPage> {
  String _pin = '';
  String _error = '';

  void _onDigitPressed(String digit) {
    setState(() {
      _error = '';
      if (_pin.length < 4) {
        _pin += digit;
      }
      
      if (_pin.length == 4) {
        final savedPin = ref.read(pinProvider).value;
        if (savedPin == _pin) {
          // Success
          ref.read(sessionProvider.notifier).unlock();
        } else {
          // Error
          setState(() {
            _error = 'PIN incorrecto. Intenta de nuevo.';
            _pin = '';
          });
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _error = '';
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      }),
    );
  }

  Widget _buildNumpad() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        for (var i = 1; i <= 9; i++)
          _buildNumpadButton(i.toString(), () => _onDigitPressed(i.toString())),
        const SizedBox.shrink(),
        _buildNumpadButton('0', () => _onDigitPressed('0')),
        _buildNumpadButton('⌫', _onDeletePressed, isIcon: true),
      ],
    );
  }

  Widget _buildNumpadButton(String text, VoidCallback onTap, {bool isIcon = false}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: const CircleBorder(),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: isIcon ? FontWeight.normal : FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Icon(Icons.lock, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Ingresa tu PIN',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Desbloquea Gestor de Gastos',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildPinDots(),
              const SizedBox(height: 24),
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              _buildNumpad(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
