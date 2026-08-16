import 'dart:io';

void main() {
  final dir = Directory('lib');
  final entities = dir.listSync(recursive: true);
  int fileCount = 0;

  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      bool changed = false;

      // Import the utils file if needed
      final needsImport = RegExp(r'\.toStringAsFixed\(').hasMatch(content);

      if (needsImport) {
        // Calculate relative path for import
        final parts = entity.path.split('/');
        final depth = parts.length - 2; // depth from 'lib'
        String relativeImport = '';
        if (depth > 0) {
          relativeImport = List.filled(depth, '../').join('');
        }
        // Actually, just use absolute package import for simplicity:
        final importStr =
            "import 'package:gestor_gastos/core/utils/currency_utils.dart';";

        if (!content.contains('currency_utils.dart')) {
          // Find first import to insert after
          content = content.replaceFirst(
            RegExp(r'import .*;'),
            '$importStr\nimport \'package:flutter/material.dart\';', // Just a fallback, better approach:
          );

          // Better import strategy
          final importMatches = RegExp(r"import '.*';\n").allMatches(content);
          if (importMatches.isNotEmpty) {
            final lastImport = importMatches.last;
            content = content.replaceRange(
              lastImport.end,
              lastImport.end,
              "$importStr\n",
            );
          }
        }

        // Replace \$${amount.toStringAsFixed(2)}
        // Regex for '\$${<something>.toStringAsFixed(<num>)}'
        final regex = RegExp(
          r'\\\$?\$\{([^}]+)\.toStringAsFixed\(([0-9]+)\)\}',
        );
        content = content.replaceAllMapped(regex, (match) {
          final varName = match.group(1)!;
          final decimals = match.group(2)!;
          if (decimals == '0') {
            return '\${CurrencyUtils.formatAmount($varName, showDecimals: false)}';
          }
          return '\${CurrencyUtils.formatAmount($varName)}';
        });

        // Some places might just use \$$amount or similar. We will just target the fixed ones for now.
        // Also handle cases like: `Text('\$${amount.toStringAsFixed(2)}')` -> `Text(CurrencyUtils.formatAmount(amount))`
        // Wait, if we replace the inside, it becomes: `Text('${CurrencyUtils.formatAmount(amount)}')` which is fine.

        // Also handle '\\$' + varName.toStringAsFixed(2)

        entity.writeAsStringSync(content);
        fileCount++;
        print('Updated ${entity.path}');
      }
    }
  }
  print('Total files updated: \$fileCount');
}
