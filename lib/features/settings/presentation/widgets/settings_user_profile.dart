import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsUserProfile extends ConsumerWidget {
  const SettingsUserProfile({super.key});

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, dynamic user) {
    if (user == null) return;
    
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: user.username);
    String? currentPhotoPath = user.photoPath;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile == null) return;
              
              final appDir = await getApplicationDocumentsDirectory();
              final fileName = path.basename(pickedFile.path);
              final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');
              
              setState(() {
                currentPhotoPath = savedImage.path;
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Editar Perfil',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: currentPhotoPath != null ? FileImage(File(currentPhotoPath!)) : null,
                          child: currentPhotoPath == null 
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimaryContainer)
                            : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, size: 20, color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isNotEmpty) {
                          await ref.read(authNotifierProvider.notifier).updateProfile(
                            user.id,
                            newName,
                            currentPhotoPath,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: () => _showEditProfileSheet(context, ref, user),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.onPrimary, width: 3),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                backgroundImage: user?.photoPath != null ? FileImage(File(user!.photoPath!)) : null,
                child: user?.photoPath == null 
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.username ?? 'Usuario',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ],
            ),
            Text(
              'Gestor de Gastos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
