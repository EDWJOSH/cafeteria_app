import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme/app_theme.dart';

/// Resultado de pedir un permiso en tiempo de ejecución.
enum EstadoPermiso { concedido, denegado, denegadoPermanente }

/// Imagen ya recortada y comprimida, con su tamaño antes y después.
class ResultadoImagen {
  final File archivo;
  final int bytesOriginal;
  final int bytesFinal;

  const ResultadoImagen(this.archivo, this.bytesOriginal, this.bytesFinal);

  int get ahorroPorcentaje => (100 - bytesFinal * 100 / bytesOriginal).round();
}

/// Servicio nativo de cámara y galería: permisos, captura, recorte y compresión.
class MediaService {
  final ImagePicker _picker = ImagePicker();

  /// Pide el permiso que corresponde a la fuente elegida.
  Future<EstadoPermiso> solicitarPermiso(ImageSource fuente) async {
    final Permission permiso;
    if (fuente == ImageSource.camera) {
      permiso = Permission.camera;
    } else if (Platform.isIOS) {
      permiso = Permission.photos;
    } else {
      // Android 13+ usa el selector de fotos del sistema: no necesita permiso.
      return EstadoPermiso.concedido;
    }

    var estado = await permiso.status;
    if (estado.isGranted || estado.isLimited) return EstadoPermiso.concedido;
    if (estado.isPermanentlyDenied) return EstadoPermiso.denegadoPermanente;

    estado = await permiso.request();
    if (estado.isGranted || estado.isLimited) return EstadoPermiso.concedido;
    if (estado.isPermanentlyDenied) return EstadoPermiso.denegadoPermanente;
    return EstadoPermiso.denegado;
  }

  /// Captura (o elige) una foto, la recorta en cuadrado y la comprime.
  /// Devuelve null si el usuario cancela en cualquier paso.
  Future<ResultadoImagen?> obtenerFoto(ImageSource fuente) async {
    final foto = await _picker.pickImage(
      source: fuente,
      preferredCameraDevice: CameraDevice.front,
    );
    if (foto == null) return null;
    final bytesOriginal = await foto.length();

    final recorte = await ImageCropper().cropImage(
      sourcePath: foto.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recortar foto',
          toolbarColor: AppColors.espresso,
          toolbarWidgetColor: AppColors.crema,
          statusBarLight: false,
          activeControlsWidgetColor: AppColors.terracota,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Recortar foto',
          aspectRatioLockEnabled: true,
          cropStyle: CropStyle.circle,
        ),
      ],
    );
    if (recorte == null) return null;

    final carpeta = await getApplicationDocumentsDirectory();
    final destino =
        '${carpeta.path}/perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final comprimida = await FlutterImageCompress.compressAndGetFile(
      recorte.path,
      destino,
      minWidth: 600,
      minHeight: 600,
      quality: 70,
    );
    if (comprimida == null) return null;

    return ResultadoImagen(
      File(comprimida.path),
      bytesOriginal,
      await comprimida.length(),
    );
  }

  Future<bool> abrirAjustes() => openAppSettings();
}
