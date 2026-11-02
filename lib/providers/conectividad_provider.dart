import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/connectivity_service.dart';

/// Gestión de estado de la conectividad. Escucha el Stream del servicio
/// y avisa a la interfaz con notifyListeners().
class ConectividadProvider extends ChangeNotifier {
  final ConnectivityService _servicio;
  StreamSubscription<EstadoRed>? _suscripcion;

  EstadoRed _estado = EstadoRed.enLinea;
  bool _verificado = false;

  /// Se llama cuando el estado cambia (lo usa el módulo de notificaciones).
  void Function(EstadoRed anterior, EstadoRed nuevo)? alCambiar;

  ConectividadProvider(this._servicio) {
    _iniciar();
  }

  EstadoRed get estado => _estado;
  bool get verificado => _verificado;
  bool get enLinea => _estado == EstadoRed.enLinea;

  Future<void> _iniciar() async {
    _actualizar(await _servicio.estadoActual());
    _suscripcion = _servicio.cambios.listen(_actualizar);
  }

  Future<void> reintentar() async =>
      _actualizar(await _servicio.estadoActual());

  void _actualizar(EstadoRed nuevo) {
    if (_verificado && nuevo == _estado) return;
    final anterior = _estado;
    final primeraLectura = !_verificado;
    _estado = nuevo;
    _verificado = true;
    notifyListeners();
    if (!primeraLectura) alCambiar?.call(anterior, nuevo);
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
