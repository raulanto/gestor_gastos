import 'dart:io';

void addImport(String path, String importLine) {
  final file = File(path);
  var content = file.readAsStringSync();
  if (!content.contains(importLine)) {
    content = '$importLine\n$content';
    file.writeAsStringSync(content);
  }
}

void main() {
  addImport('lib/features/budgets/application/budget_notification_watcher.dart', "import 'package:flutter_riverpod/flutter_riverpod.dart';");
  addImport('lib/features/home/presentation/widgets/home_header.dart', "import 'dart:io';");
  addImport('lib/features/loans/presentation/widgets/loan_card.dart', "import 'dart:io';");
  addImport('lib/features/loans/presentation/widgets/loan_details_header.dart', "import 'dart:io';");
  addImport('lib/features/transactions/presentation/pages/add_transaction_page.dart', "import 'dart:io';");
}
