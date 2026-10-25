import 'package:flutter_test/flutter_test.dart';

import 'package:cafeteria_app/main.dart';

void main() {
  testWidgets('La pantalla principal muestra el título y el menú', (WidgetTester tester) async {
    await tester.pumpWidget(const CafeteriaApp());

    expect(find.text('Café Aroma'), findsOneWidget);
    expect(find.text('Nuestro menú'), findsOneWidget);
    expect(find.text('Capuchino'), findsOneWidget);
  });
}
