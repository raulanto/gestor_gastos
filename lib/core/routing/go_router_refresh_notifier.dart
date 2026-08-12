import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/pin_provider.dart';
import '../../features/auth/presentation/providers/session_provider.dart';

/// Traduce cambios de providers de Riverpod en notificaciones
/// que go_router puede escuchar vía `refreshListenable`.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    // Cada ref.listen agrega un "disparador" de refresh.
    // No importa el valor, solo que algo cambió.
    _authSub = _ref.listen(
      authNotifierProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
    _pinSub = _ref.listen(
      pinProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
    _sessionSub = _ref.listen(
      sessionProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  late final ProviderSubscription _authSub;
  late final ProviderSubscription _pinSub;
  late final ProviderSubscription _sessionSub;

  @override
  void dispose() {
    _authSub.close();
    _pinSub.close();
    _sessionSub.close();
    super.dispose();
  }
}

final goRouterRefreshNotifierProvider =
    Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
