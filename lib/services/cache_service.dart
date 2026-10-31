import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';

/// Catálogo leído desde la caché junto con la fecha en que se guardó.
class CatalogoGuardado {
  final List<Producto> productos;
  final DateTime fecha;

  const CatalogoGuardado(this.productos, this.fecha);
}

/// Persistencia local (SharedPreferences). Permite que la app siga
/// funcionando sin internet con los últimos datos descargados.
class CacheService {
  static const _claveCatalogo = 'catalogo_json';
  static const _claveFechaCatalogo = 'catalogo_fecha';
  static const _claveUltimoPedido = 'ultimo_pedido';
  static const _claveFotoPerfil = 'foto_perfil';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<void> guardarCatalogo(List<Producto> productos) async {
    final json = jsonEncode(productos.map((p) => p.toJson()).toList());
    await _prefs.setString(_claveCatalogo, json);
    await _prefs.setString(
      _claveFechaCatalogo,
      DateTime.now().toIso8601String(),
    );
  }

  CatalogoGuardado? leerCatalogo() {
    final json = _prefs.getString(_claveCatalogo);
    final fecha = _prefs.getString(_claveFechaCatalogo);
    if (json == null || fecha == null) return null;

    final lista = (jsonDecode(json) as List)
        .map((item) => Producto.fromJson(item as Map<String, dynamic>))
        .toList();
    return CatalogoGuardado(lista, DateTime.parse(fecha));
  }

  String? get ultimoPedido => _prefs.getString(_claveUltimoPedido);
  Future<void> guardarUltimoPedido(String resumen) =>
      _prefs.setString(_claveUltimoPedido, resumen);

  String? get fotoPerfil => _prefs.getString(_claveFotoPerfil);
  Future<void> guardarFotoPerfil(String ruta) =>
      _prefs.setString(_claveFotoPerfil, ruta);
}
