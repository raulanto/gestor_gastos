import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PeriodView { day, week, month, year }

class PeriodViewNotifier extends Notifier<PeriodView> {
  @override
  PeriodView build() => PeriodView.month;

  void updateView(PeriodView view) {
    state = view;
  }
}

final periodViewProvider = NotifierProvider<PeriodViewNotifier, PeriodView>(
  PeriodViewNotifier.new,
);
