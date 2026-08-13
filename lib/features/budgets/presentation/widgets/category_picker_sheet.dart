import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category.dart';
import 'package:gestor_gastos/core/utils/icon_utils.dart';

Future<void> showCategoryPickerSheet({
  required BuildContext context,
  required List<Category> categories,
  required Function(Category) onSelected,
}) async {
  final mainCategories = categories.where((c) => c.parentId == null).toList();
  final subCategories = categories.where((c) => c.parentId != null).toList();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Seleccionar Categoría', style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: mainCategories.length,
                  itemBuilder: (context, index) {
                    final main = mainCategories[index];
                    final children = subCategories.where((c) => c.parentId == main.id).toList();

                    if (children.isEmpty) {
                      return ListTile(
                        leading: Icon(IconUtils.getIcon(main.iconCode), color: Color(main.colorCode)),
                        title: Text(main.name),
                        onTap: () {
                          onSelected(main);
                          Navigator.pop(context);
                        },
                      );
                    }
                    return ExpansionTile(
                      leading: Icon(IconUtils.getIcon(main.iconCode), color: Color(main.colorCode)),
                      title: Text(main.name),
                      children: children.map((child) => ListTile(
                        contentPadding: const EdgeInsets.only(left: 72.0, right: 16.0),
                        leading: Icon(IconUtils.getIcon(child.iconCode), color: Color(child.colorCode)),
                        title: Text(child.name),
                        onTap: () {
                          onSelected(child);
                          Navigator.pop(context);
                        },
                      )).toList(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  );
}
