import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cafeteria_app/main.dart';

void main() {
  testWidgets('La pantalla principal muestra el título y el menú', (WidgetTester tester) async {
    await tester.pumpWidget(const CafeteriaApp());

    expect(find.text('Café Aroma'), findsOneWidget);
    expect(find.text('Nuestro menú'), findsOneWidget);
    expect(find.text('Capuchino'), findsOneWidget);
  });

  testWidgets('Navega al detalle con el producto y regresa con el pedido', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CafeteriaApp());

    // Ida: tocar "Ver" en el Capuchino (segundo producto)
    await tester.tap(find.text('Ver').at(1));
    await tester.pumpAndSettle();
    expect(find.text('Parámetro recibido desde Home: producto #2 - Capuchino'), findsOneWidget);

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
    expect(find.text('Edwin pidió 2 x Capuchino (Mediano) - Total \$5.00'), findsOneWidget);
  });
}
