import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category.dart';
import 'category_picker_sheet.dart';

class TransactionCategorySelector extends StatelessWidget {
  final Category? selectedCategory;
  final List<Category>? categories;
  final ValueChanged<Category> onSelected;

  const TransactionCategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (categories == null) return;
        showCategoryPickerSheet(
          context: context,
          categories: categories!,
          onSelected: onSelected,
        );
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
        child: Row(
          children: [
            if (selectedCategory != null)
              Icon(IconData(selectedCategory!.iconCode, fontFamily: 'MaterialIcons'), color: Color(selectedCategory!.colorCode)),
            const SizedBox(width: 8),
            Text(selectedCategory != null ? selectedCategory!.name : 'Seleccionar Categoría'),
          ],
        ),
      ),
    );
  }
}
