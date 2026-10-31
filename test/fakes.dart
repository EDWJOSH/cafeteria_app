import 'dart:async';
import 'dart:convert';

import 'package:grano_co/data/catalogo_repository.dart';
import 'package:grano_co/main.dart';
import 'package:grano_co/services/cache_service.dart';
import 'package:grano_co/services/connectivity_service.dart';
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

Future<Servicios> serviciosDePrueba(
  FakeConnectivityService conectividad,
) async {
  SharedPreferences.setMockInitialValues({});
  final cache = CacheService(await SharedPreferences.getInstance());
  return Servicios(
    cache: cache,
    conectividad: conectividad,
    catalogo: CatalogoRepository(cache, cliente: clienteFalso()),
  );
}
