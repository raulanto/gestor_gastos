import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';
import 'category_picker_sheet.dart';

class TransactionSplitList extends StatelessWidget {
  final List<TransactionSplit> splits;
  final List<Category>? categories;
  final VoidCallback onAddSplit;
  final ValueChanged<TransactionSplit> onRemoveSplit;

  const TransactionSplitList({
    super.key,
    required this.splits,
    required this.categories,
    required this.onAddSplit,
    required this.onRemoveSplit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (splits.isNotEmpty)
          ...splits.map((s) {
            final cat = categories?.where((c) => c.id == s.categoryId).firstOrNull;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: cat != null ? Icon(IconData(cat.iconCode, fontFamily: 'MaterialIcons'), color: Color(cat.colorCode)) : const Icon(Icons.category),
              title: Text(cat?.name ?? 'Desconocida'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\$${s.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onRemoveSplit(s),
                  )
                ],
              ),
            );
          }),
        OutlinedButton.icon(
          onPressed: onAddSplit,
          icon: const Icon(Icons.add),
          label: const Text('Añadir División'),
        )
      ],
    );
  }
}
