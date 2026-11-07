import 'package:flutter/foundation.dart';

import '../models/clima.dart';
import '../services/clima_api_service.dart';

/// Estados de la petición a la API.
enum EstadoClima { inicial, cargando, exito, error }

/// Gestión de estado del clima: la pantalla solo lee estos valores.
class ClimaProvider extends ChangeNotifier {
  /// Desde esta temperatura se recomiendan bebidas frías.
  static const umbralCalor = 26.0;

  final ClimaApiService _api;

  EstadoClima _estado = EstadoClima.inicial;
  Clima? _clima;
  String? _mensajeError;
  DateTime? _actualizado;

  ClimaProvider(this._api);

  EstadoClima get estado => _estado;
  Clima? get clima => _clima;
  String? get mensajeError => _mensajeError;
  DateTime? get actualizado => _actualizado;
  bool get haceCalor => (_clima?.actual.temperatura ?? 0) >= umbralCalor;

  /// Pide los datos a la API y va cambiando de estado:
  /// cargando -> exito (con datos) o cargando -> error (con mensaje).
  Future<void> cargar() async {
    if (_estado == EstadoClima.cargando) return;
    _estado = EstadoClima.cargando;
    _mensajeError = null;
    notifyListeners();

    try {
      _clima = await _api.obtenerClima();
      _actualizado = DateTime.now();
      _estado = EstadoClima.exito;
    } on ClimaException catch (e) {
      _mensajeError = e.mensaje;
      _estado = EstadoClima.error;
    }
    notifyListeners();
  }
}
