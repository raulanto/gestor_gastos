import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pin_provider.dart';
import '../providers/session_provider.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _error = '';

  void _onDigitPressed(String digit) {
    setState(() {
      _error = '';
      if (!_isConfirming) {
        if (_pin.length < 4) {
          _pin += digit;
        }
        if (_pin.length == 4) {
          // Pass to confirmation step automatically
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _isConfirming = true;
              });
            }
          });
        }
      } else {
        if (_confirmPin.length < 4) {
          _confirmPin += digit;
        }
        if (_confirmPin.length == 4) {
          if (_pin == _confirmPin) {
            // Success
            ref.read(pinProvider.notifier).setPin(_pin).then((_) {
              ref.read(sessionProvider.notifier).unlock();
            });
          } else {
            // Error, reset confirmation
            _error = 'Los PIN no coinciden. Intenta de nuevo.';
            _confirmPin = '';
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _error = '';
      if (!_isConfirming) {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          // Go back to step 1
          _isConfirming = false;
          _pin = '';
        }
      }
    });
  }

  Widget _buildPinDots(String currentPin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < currentPin.length;
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
    final title = _isConfirming ? 'Confirma tu PIN' : 'Crea tu PIN';
    final subtitle = _isConfirming ? 'Vuelve a ingresarlo' : 'Protege tu información';
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildPinDots(currentPin),
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
