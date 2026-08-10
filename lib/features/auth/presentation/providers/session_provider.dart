import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Por defecto está bloqueado al arrancar
  }

  void unlock() {
    state = true;
  }

  void lock() {
    state = false;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, bool>(() {
  return SessionNotifier();
});
