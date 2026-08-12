import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loans_provider.dart';
import '../widgets/loans_background.dart';
import '../widgets/loans_header.dart';
import '../widgets/loans_content.dart';

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansProvider);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          const LoansBackground(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoansHeader(),
              Expanded(
                child: LoansContent(loansAsync: loansAsync),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
