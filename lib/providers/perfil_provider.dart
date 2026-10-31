import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../services/cache_service.dart';
import '../services/media_service.dart';

/// Estado de la foto de perfil del cliente.
class PerfilProvider extends ChangeNotifier {
  final MediaService _media;
  final CacheService _cache;

  File? _foto;
  ResultadoImagen? _ultimoResultado;
  bool _procesando = false;
  String? _error;

  PerfilProvider(this._media, this._cache) {
    final ruta = _cache.fotoPerfil;
    if (ruta != null && File(ruta).existsSync()) _foto = File(ruta);
  }

  File? get foto => _foto;
  ResultadoImagen? get ultimoResultado => _ultimoResultado;
  bool get procesando => _procesando;
  String? get error => _error;

  /// Pide el permiso y, si se concede, captura/recorta/comprime la foto.
  /// Devuelve el estado del permiso para que la pantalla decida qué mostrar.
  Future<EstadoPermiso> cambiarFoto(ImageSource fuente) async {
    final permiso = await _media.solicitarPermiso(fuente);
    if (permiso != EstadoPermiso.concedido) return permiso;

    _procesando = true;
    _error = null;
    notifyListeners();
    try {
      final resultado = await _media.obtenerFoto(fuente);
      if (resultado != null) {
        final anterior = _foto;
        _foto = resultado.archivo;
        _ultimoResultado = resultado;
        await _cache.guardarFotoPerfil(resultado.archivo.path);
        if (anterior != null && anterior.existsSync()) await anterior.delete();
      }
    } catch (e) {
      _error = 'No se pudo procesar la imagen: $e';
    } finally {
      _procesando = false;
      notifyListeners();
    }
    return permiso;
  }

  Future<bool> abrirAjustes() => _media.abrirAjustes();
}
