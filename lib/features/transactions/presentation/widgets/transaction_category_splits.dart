import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

class TransactionCategorySplits extends StatelessWidget {
  final TransactionEntity transaction;
  final List<Category> categories;

  const TransactionCategorySplits({
    super.key,
    required this.transaction,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (transaction.splits.length <= 1 && transaction.categoryId != null) {
      final cat = categories.where((c) => c.id == transaction.categoryId).firstOrNull;
      return ListTile(
        leading: Icon(
          cat != null ? IconData(cat.iconCode, fontFamily: 'MaterialIcons') : Icons.category,
          color: cat != null ? Color(cat.colorCode) : Colors.grey,
          size: 32,
        ),
        title: const Text('Categoría'),
        subtitle: Text(
          cat?.name ?? 'Desconocida',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    } else if (transaction.splits.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Divisiones (Splits)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...transaction.splits.map((s) {
            final cat = categories.where((c) => c.id == s.categoryId).firstOrNull;
            return ListTile(
              dense: true,
              leading: Icon(
                cat != null ? IconData(cat.iconCode, fontFamily: 'MaterialIcons') : Icons.category,
                color: cat != null ? Color(cat.colorCode) : Colors.grey,
              ),
              title: Text(cat?.name ?? 'Desconocida'),
              trailing: Text(
                '\$${s.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            );
          }),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
