import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notification_preferences_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  String _getLabelForType(String type) {
    switch (type) {
      case 'budget':
        return 'Alertas de Presupuesto';
      case 'savings':
        return 'Metas de Ahorro';
      case 'recurring':
        return 'Gastos Recurrentes';
      case 'daily_reminder':
        return 'Recordatorio Diario';
      case 'summary':
        return 'Resumen Semanal/Mensual';
      default:
        return type;
    }
  }

  String _getSubtitleForType(String type) {
    switch (type) {
      case 'budget':
        return 'Recibe avisos al acercarte a tu límite.';
      case 'savings':
        return 'Celebra tus logros de ahorro.';
      case 'recurring':
        return 'No olvides tus pagos próximos.';
      case 'daily_reminder':
        return 'Un recordatorio para registrar gastos.';
      case 'summary':
        return 'Resumen de tu desempeño.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsState = ref.watch(notificationPreferenceNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: prefsState.when(
        data: (prefs) {
          if (prefs.isEmpty) {
            return const Center(child: Text('No hay preferencias configuradas.'));
          }
          
          return ListView.builder(
            itemCount: prefs.length,
            itemBuilder: (context, index) {
              final pref = prefs[index];
              return SwitchListTile(
                title: Text(_getLabelForType(pref.type)),
                subtitle: Text(_getSubtitleForType(pref.type)),
                value: pref.isEnabled,
                onChanged: (val) {
                  ref.read(notificationPreferenceNotifierProvider.notifier)
                     .updatePreference(pref.copyWith(isEnabled: val));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
