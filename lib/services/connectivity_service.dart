import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Estado real de la red: no basta con tener Wi-Fi, hay que llegar a internet.
enum EstadoRed { enLinea, sinInternet, sinRed }

/// Servicio nativo de conectividad. No conoce nada de la interfaz:
/// solo expone un Stream con los cambios del estado de la red.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  /// Emite un nuevo estado cada vez que el sistema operativo avisa un cambio de red.
  Stream<EstadoRed> get cambios =>
      _connectivity.onConnectivityChanged.asyncMap(_evaluar);

  Future<EstadoRed> estadoActual() async =>
      _evaluar(await _connectivity.checkConnectivity());

  Future<EstadoRed> _evaluar(List<ConnectivityResult> resultados) async {
    final sinInterfaz =
        resultados.isEmpty ||
        resultados.every((r) => r == ConnectivityResult.none);
    if (sinInterfaz) return EstadoRed.sinRed;
    return await hayInternet() ? EstadoRed.enLinea : EstadoRed.sinInternet;
  }

  /// Comprueba salida real a internet resolviendo un dominio (DNS).
  Future<bool> hayInternet() async {
    try {
      final resultado = await InternetAddress.lookup(
        'raw.githubusercontent.com',
      ).timeout(const Duration(seconds: 4));
      return resultado.isNotEmpty && resultado.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
