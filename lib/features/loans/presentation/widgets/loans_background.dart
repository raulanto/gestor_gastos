import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';

class LoansBackground extends ConsumerWidget {
  const LoansBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 350,
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
                theme.colorScheme.primary,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
