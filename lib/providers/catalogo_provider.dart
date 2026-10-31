import 'package:flutter/foundation.dart';

import '../data/catalogo_repository.dart';
import '../models/producto.dart';

/// Estado del catálogo. Se recarga solo cuando la app recupera la conexión.
class CatalogoProvider extends ChangeNotifier {
  final CatalogoRepository _repositorio;

  List<Producto> _productos = [];
  OrigenCatalogo? _origen;
  DateTime? _actualizado;
  bool _cargando = false;
  bool? _enLinea;

  CatalogoProvider(this._repositorio);

  List<Producto> get productos => _productos;
  OrigenCatalogo? get origen => _origen;
  DateTime? get actualizado => _actualizado;
  bool get cargando => _cargando;

  /// La llama el ProxyProvider cada vez que cambia ConectividadProvider.
  void actualizarConexion({required bool verificado, required bool enLinea}) {
    if (!verificado || _enLinea == enLinea) return;
    final primeraVez = _enLinea == null;
    final reconecto = _enLinea == false && enLinea;
    _enLinea = enLinea;
    if (primeraVez || reconecto) Future.microtask(cargar);
  }

  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();

    final resultado = await _repositorio.obtener(enLinea: _enLinea ?? false);
    _productos = resultado.productos;
    _origen = resultado.origen;
    _actualizado = resultado.actualizado;
    _cargando = false;
    notifyListeners();
  }
}
