import 'package:flutter/foundation.dart';

import '../services/cache_service.dart';
import '../services/notification_service.dart';

/// Estado del último pedido. Al registrarlo lo guarda y dispara la notificación.
class PedidoProvider extends ChangeNotifier {
  final CacheService _cache;
  final NotificationService _notificaciones;

  PedidoProvider(this._cache, this._notificaciones);

  String? get ultimoPedido => _cache.ultimoPedido;

  Future<void> registrar(String resumen) async {
    await _cache.guardarUltimoPedido(resumen);
    notifyListeners();
    await _notificaciones.pedidoConfirmado(resumen);
  }
}
