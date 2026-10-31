import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/producto.dart';
import '../services/cache_service.dart';

/// De dónde salieron los productos que se están mostrando.
enum OrigenCatalogo { red, cache, local }

class ResultadoCatalogo {
  final List<Producto> productos;
  final OrigenCatalogo origen;
  final DateTime? actualizado;

  const ResultadoCatalogo(this.productos, this.origen, this.actualizado);
}

/// Decide de dónde obtener el catálogo: red -> caché -> menú básico.
class CatalogoRepository {
  static const urlCatalogo =
      'https://raw.githubusercontent.com/EDWJOSH/cafeteria_app/develop/assets/data/catalogo.json';

  final CacheService _cache;
  final http.Client _cliente;

  CatalogoRepository(this._cache, {http.Client? cliente})
    : _cliente = cliente ?? http.Client();

  Future<ResultadoCatalogo> obtener({required bool enLinea}) async {
    if (enLinea) {
      try {
        final respuesta = await _cliente
            .get(Uri.parse(urlCatalogo))
            .timeout(const Duration(seconds: 8));
        if (respuesta.statusCode == 200) {
          final productos =
              (jsonDecode(utf8.decode(respuesta.bodyBytes)) as List)
                  .map(
                    (item) => Producto.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
          await _cache.guardarCatalogo(productos);
          return ResultadoCatalogo(
            productos,
            OrigenCatalogo.red,
            DateTime.now(),
          );
        }
      } catch (_) {
        // Si la descarga falla seguimos con la caché (estrategia offline-first).
      }
    }

    final guardado = _cache.leerCatalogo();
    if (guardado != null) {
      return ResultadoCatalogo(
        guardado.productos,
        OrigenCatalogo.cache,
        guardado.fecha,
      );
    }
    return const ResultadoCatalogo(catalogoBase, OrigenCatalogo.local, null);
  }
}
