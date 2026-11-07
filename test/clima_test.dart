import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grano_co/main.dart';
import 'package:grano_co/models/clima.dart';
import 'package:grano_co/services/clima_api_service.dart';
import 'package:grano_co/services/connectivity_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fakes.dart';

void main() {
  group('Modelo Clima (fromJson / toJson)', () {
    final json = jsonDecode(climaJsonDePrueba) as Map<String, dynamic>;

    test('fromJson une los arreglos de "daily" en objetos PronosticoDia', () {
      final clima = Clima.fromJson(json);

      expect(clima.actual.temperatura, 29.2);
      expect(clima.actual.humedad, 69);
      expect(clima.dias, hasLength(3));
      expect(clima.dias[1].fecha, DateTime(2026, 11, 8));
      expect(clima.dias[1].maxima, 32.9);
      expect(clima.dias[0].probabilidadLluvia, 45);
    });

    test('toJson devuelve la misma estructura que entrega la API', () {
      final copia = Clima.fromJson(Clima.fromJson(json).toJson());

      expect(copia.dias.map((d) => d.minima), [24.1, 24.2, 24.6]);
      expect(copia.actual.codigoClima, 1);
      expect(copia.zonaHoraria, 'America/Guayaquil');
    });
  });

  group('ClimaApiService (manejo de errores)', () {
    test('HTTP 500 se convierte en ClimaException', () async {
      final api = ClimaApiService(
        cliente: MockClient((_) async => http.Response('error', 500)),
      );
      expect(
        api.obtenerClima(),
        throwsA(
          isA<ClimaException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('500'),
          ),
        ),
      );
    });

    test('Sin red (SocketException) muestra un mensaje claro', () async {
      final api = ClimaApiService(
        cliente: MockClient(
          (_) async => throw const SocketException('sin red'),
        ),
      );
      expect(
        api.obtenerClima(),
        throwsA(
          isA<ClimaException>().having(
            (e) => e.mensaje,
            'mensaje',
            startsWith('Sin conexión a internet'),
          ),
        ),
      );
    });

    test('JSON con otra estructura se reporta como respuesta dañada', () async {
      final api = ClimaApiService(
        cliente: MockClient((_) async => http.Response('{"current": 5}', 200)),
      );
      expect(api.obtenerClima(), throwsA(isA<ClimaException>()));
    });
  });

  group('Pantalla Clima y antojo (estados)', () {
    Future<void> abrirClima(WidgetTester tester, ClimaApiService api) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      final servicios = await serviciosDePrueba(
        FakeConnectivityService(EstadoRed.enLinea),
        clima: api,
      );
      await tester.pumpWidget(GranoApp(servicios: servicios));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clima y antojo'));
      await tester.pump(); // abre la pantalla
      await tester.pump(); // primer frame: se dispara la petición
    }

    testWidgets('Cargando -> Éxito con datos y recomendación', (tester) async {
      // El servidor falso retiene la respuesta hasta que la prueba la libere.
      final respuesta = Completer<http.Response>();
      final api = ClimaApiService(cliente: MockClient((_) => respuesta.future));
      await abrirClima(tester, api);

      expect(find.text('Consultando el clima en Guayaquil...'), findsOneWidget);

      respuesta.complete(
        http.Response.bytes(utf8.encode(climaJsonDePrueba), 200),
      );
      await tester.pumpAndSettle();
      expect(find.text('29.2 °C'), findsOneWidget);
      expect(
        find.text('Hace calor: te recomendamos algo frío'),
        findsOneWidget,
      );
      expect(find.text('Cold brew de la casa'), findsWidgets);
      expect(find.text('Hoy'), findsOneWidget);
    });

    testWidgets('Error de conexión y recuperación con Reintentar', (
      tester,
    ) async {
      var fallar = true;
      final api = ClimaApiService(
        cliente: MockClient((_) async {
          if (fallar) throw const SocketException('sin red');
          return http.Response.bytes(utf8.encode(climaJsonDePrueba), 200);
        }),
      );
      await abrirClima(tester, api);
      await tester.pumpAndSettle();

      expect(find.text('No pudimos cargar el clima'), findsOneWidget);
      expect(find.textContaining('Sin conexión a internet'), findsOneWidget);

      fallar = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('29.2 °C'), findsOneWidget);
    });
  });
}
