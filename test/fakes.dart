import 'dart:async';
import 'dart:convert';

import 'package:grano_co/data/catalogo_repository.dart';
import 'package:grano_co/main.dart';
import 'package:grano_co/services/cache_service.dart';
import 'package:grano_co/services/clima_api_service.dart';
import 'package:grano_co/services/connectivity_service.dart';
import 'package:grano_co/services/media_service.dart';
import 'package:grano_co/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Conectividad falsa: la prueba decide cuándo hay o no internet.
class FakeConnectivityService extends ConnectivityService {
  EstadoRed estado;
  final _controller = StreamController<EstadoRed>.broadcast();

  FakeConnectivityService(this.estado);

  @override
  Stream<EstadoRed> get cambios => _controller.stream;

  @override
  Future<EstadoRed> estadoActual() async => estado;

  void cambiarA(EstadoRed nuevo) {
    estado = nuevo;
    _controller.add(nuevo);
  }
}

/// Media falso: simula la respuesta del usuario al diálogo de permisos.
class FakeMediaService extends MediaService {
  EstadoPermiso respuesta;
  bool ajustesAbiertos = false;

  FakeMediaService([this.respuesta = EstadoPermiso.concedido]);

  @override
  Future<EstadoPermiso> solicitarPermiso(ImageSource fuente) async => respuesta;

  @override
  Future<ResultadoImagen?> obtenerFoto(ImageSource fuente) async => null;

  @override
  Future<bool> abrirAjustes() async => ajustesAbiertos = true;
}

/// Notificaciones falsas: guarda los títulos en vez de mostrarlos.
class FakeNotificationService extends NotificationService {
  final List<String> enviadas = [];

  @override
  Future<void> inicializar() async {}

  @override
  Future<bool> solicitarPermiso() async => true;

  @override
  Future<void> mostrar(
    AndroidNotificationChannel canal,
    String titulo,
    String cuerpo,
  ) async => enviadas.add('${canal.id}: $titulo');
}

/// Respuesta del "servidor": el catálogo remoto trae el Cold brew (id 6).
http.Client clienteFalso() => MockClient((request) async {
  final json = jsonEncode([
    {
      'id': 2,
      'nombre': 'Capuchino',
      'descripcion': 'Espresso con leche.',
      'precio': 2.5,
      'categoria': 'Bebidas calientes',
      'icono': 'capuchino',
    },
    {
      'id': 6,
      'nombre': 'Cold brew de la casa',
      'descripcion': 'Extraído en frío.',
      'precio': 3.5,
      'categoria': 'Bebidas frías',
      'icono': 'coldbrew',
    },
  ]);
  return http.Response.bytes(utf8.encode(json), 200);
});

/// Respuesta real de Open-Meteo recortada (misma estructura que la API).
const climaJsonDePrueba = '''
{
  "timezone": "America/Guayaquil",
  "current": {"time": "2026-11-07T10:45", "temperature_2m": 29.2,
    "apparent_temperature": 36.0, "relative_humidity_2m": 69,
    "weather_code": 1, "wind_speed_10m": 1.4},
  "daily": {
    "time": ["2026-11-07", "2026-11-08", "2026-11-09"],
    "weather_code": [80, 53, 3],
    "temperature_2m_max": [30.9, 32.9, 31.2],
    "temperature_2m_min": [24.1, 24.2, 24.6],
    "precipitation_probability_max": [45, 20, 5]
  }
}
''';

/// Servicio de clima con un servidor falso que responde [climaJsonDePrueba].
ClimaApiService climaFalso() => ClimaApiService(
  cliente: MockClient(
    (request) async => http.Response.bytes(utf8.encode(climaJsonDePrueba), 200),
  ),
);

Future<Servicios> serviciosDePrueba(
  FakeConnectivityService conectividad, {
  MediaService? media,
  NotificationService? notificaciones,
  ClimaApiService? clima,
}) async {
  SharedPreferences.setMockInitialValues({});
  final cache = CacheService(await SharedPreferences.getInstance());
  return Servicios(
    cache: cache,
    conectividad: conectividad,
    catalogo: CatalogoRepository(cache, cliente: clienteFalso()),
    media: media ?? FakeMediaService(),
    notificaciones: notificaciones ?? FakeNotificationService(),
    clima: clima ?? climaFalso(),
  );
}
