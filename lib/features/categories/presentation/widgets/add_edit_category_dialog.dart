import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/category_provider.dart';

class AddEditCategoryDialog extends ConsumerStatefulWidget {
  final Category? category;

  const AddEditCategoryDialog({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends ConsumerState<AddEditCategoryDialog> {
  late TextEditingController _nameController;
  late int _selectedIcon;
  late int _selectedColor;
  int? _selectedParentId;

  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.directions_car,
    Icons.home,
    Icons.health_and_safety,
    Icons.flight,
    Icons.computer,
    Icons.movie,
    Icons.pets,
  ];

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedIcon = widget.category?.iconCode ?? _availableIcons.first.codePoint;
    _selectedColor = widget.category?.colorCode ?? _availableColors.first.toARGB32();
    _selectedParentId = widget.category?.parentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingrese un nombre')));
      return;
    }

    // A category cannot be its own parent
    if (widget.category != null && widget.category!.id == _selectedParentId) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Una categoría no puede ser padre de sí misma')));
      return;
    }

    final newCategory = Category(
      id: widget.category?.id ?? 0,
      name: name,
      iconCode: _selectedIcon,
      colorCode: _selectedColor,
      parentId: _selectedParentId,
    );

    if (widget.category == null) {
      ref.read(categoriesProvider.notifier).addCategory(newCategory);
    } else {
      ref.read(categoriesProvider.notifier).updateCategory(newCategory);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);

    return AlertDialog(
      title: Text(widget.category == null ? 'Nueva Categoría' : 'Editar Categoría'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            // Parent Selector
            categoriesState.when(
              data: (categories) {
                // Solo permitimos elegir como padre a categorías principales
                final mainCategories = categories.where((c) => c.parentId == null && c.id != widget.category?.id).toList();
                
                if (mainCategories.isEmpty) return const SizedBox.shrink();

                return DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(labelText: 'Categoría Padre (Opcional)', border: OutlineInputBorder()),
                  initialValue: _selectedParentId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Ninguna (Principal)')),
                    ...mainCategories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ))
                  ],
                  onChanged: (val) => setState(() => _selectedParentId = val),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            if (categoriesState.value?.any((c) => c.parentId == null && c.id != widget.category?.id) == true)
              const SizedBox(height: 16),

            const Text('Icono', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = icon.codePoint == _selectedIcon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon.codePoint),
                  child: CircleAvatar(
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                    child: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color.toARGB32() == _selectedColor;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color.toARGB32()),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
