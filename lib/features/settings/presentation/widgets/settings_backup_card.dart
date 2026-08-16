import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gestor_gastos/core/database/backup_service.dart';

class SettingsBackupCard extends ConsumerWidget {
  const SettingsBackupCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.save_alt, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Datos y Respaldo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.upload_file,
              color: theme.colorScheme.onSurface,
            ),
            title: const Text('Exportar Datos (JSON)'),
            subtitle: const Text('Guardar todos los registros'),
            onTap: () => _exportData(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.download, color: theme.colorScheme.error),
            title: Text(
              'Importar Datos',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text(
              'Restaura desde un archivo JSON (sobrescribe datos actuales)',
            ),
            onTap: () => _importData(context, ref),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final jsonString = await ref.read(backupServiceProvider).exportData();
      final bytes = utf8.encode(jsonString);

      final Uri? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Guardar respaldo de Gestor Gastos',
        fileName: 'gestor_gastos_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(bytes),
      );

      if (outputFile != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Respaldo guardado exitosamente')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Advertencia'),
        content: const Text(
          'Al importar un respaldo, se borrarán TODOS tus datos actuales. Esta acción no se puede deshacer. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Importar y Sobrescribir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.path != null) {
        final file = File(result.path!);
        final jsonString = await file.readAsString();

        await ref.read(backupServiceProvider).importData(jsonString);

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Éxito'),
              content: const Text(
                'Datos restaurados correctamente. Por favor, reinicia la aplicación para aplicar todos los cambios.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () =>
                      exit(0), // Cierra la app para forzar el reinicio
                  child: const Text('Cerrar App'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al importar: $e')));
      }
    }
  }
}
