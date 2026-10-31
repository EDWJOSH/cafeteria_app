import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grano_co/main.dart';
import 'package:grano_co/services/connectivity_service.dart';

import 'fakes.dart';

void main() {
  Future<void> abrirApp(
    WidgetTester tester,
    FakeConnectivityService red,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final servicios = await serviciosDePrueba(red);
    await tester.pumpWidget(GranoApp(servicios: servicios));
    await tester.pumpAndSettle();
  }

  testWidgets('Con internet muestra el menú descargado de la red', (
    tester,
  ) async {
    await abrirApp(tester, FakeConnectivityService(EstadoRed.enLinea));

    expect(find.text('Grano & Co.'), findsOneWidget);
    expect(find.text('Cold brew de la casa'), findsOneWidget);
    expect(
      find.textContaining('Menú actualizado desde internet'),
      findsOneWidget,
    );
    expect(find.text('Sin conexión a internet'), findsNothing);
  });

  testWidgets('Sin internet muestra el banner offline y el menú básico', (
    tester,
  ) async {
    await abrirApp(tester, FakeConnectivityService(EstadoRed.sinRed));

    expect(find.text('Sin conexión a internet'), findsOneWidget);
    expect(
      find.text('Mostrando el menú básico incluido en la app'),
      findsOneWidget,
    );
    expect(find.text('Cold brew de la casa'), findsNothing);
  });

  testWidgets('Al perder la red usa la caché y al volver se recarga', (
    tester,
  ) async {
    final red = FakeConnectivityService(EstadoRed.enLinea);
    await abrirApp(tester, red);

    red.cambiarA(EstadoRed.sinRed);
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión a internet'), findsOneWidget);
    expect(
      find.textContaining('Mostrando el menú guardado el'),
      findsOneWidget,
    );
    expect(find.text('Cold brew de la casa'), findsOneWidget);

    red.cambiarA(EstadoRed.enLinea);
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión a internet'), findsNothing);
  });

  testWidgets('Navega al detalle con el producto y regresa con el pedido', (
    tester,
  ) async {
    await abrirApp(tester, FakeConnectivityService(EstadoRed.enLinea));

    // Ida: tocar "Ver" en el Capuchino (primer producto del catálogo remoto)
    await tester.tap(find.text('Ver').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Parámetro recibido desde Home: producto #2 - Capuchino'),
      findsOneWidget,
    );

    // Sin nombre el formulario no deja confirmar
    await tester.ensureVisible(find.text('Confirmar pedido'));
    await tester.tap(find.text('Confirmar pedido'));
    await tester.pump();
    expect(find.text('Escribe tu nombre para el pedido'), findsOneWidget);

    // Vuelta: llenar el nombre, sumar uno y confirmar
    await tester.enterText(find.byType(TextFormField), 'Edwin');
    await tester.tap(find.byTooltip('Agregar uno'));
    await tester.pump();
    await tester.ensureVisible(find.text('Confirmar pedido'));
    await tester.tap(find.text('Confirmar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Último pedido'), findsOneWidget);
    expect(
      find.text('Edwin pidió 2 x Capuchino (Mediano) - Total \$5.00'),
      findsOneWidget,
    );
  });
}
