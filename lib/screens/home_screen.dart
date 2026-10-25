import 'package:flutter/material.dart';

import '../widgets/info_chip.dart';
import '../widgets/producto_card.dart';

/// Pantalla 1: muestra el banner, la información del local y el menú.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El detalle estará disponible pronto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Café Aroma'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        children: [
          Image.asset(
            'assets/images/banner.png',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            semanticLabel: 'Banner de Café Aroma',
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¡Bienvenido!', style: textos.headlineSmall),
                const SizedBox(height: 4),
                const Text('Elige tu bebida o postre favorito y haz tu pedido.'),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(icono: Icons.schedule, texto: 'Lun a Sáb, 7:00 - 20:00'),
                    InfoChip(icono: Icons.location_on, texto: 'Centro de la ciudad'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Nuestro menú', style: textos.titleLarge),
          ),
          ProductoCard(
            nombre: 'Café americano',
            descripcion: 'Café negro preparado con granos tostados de la casa.',
            precio: 1.50,
            icono: Icons.coffee,
            onVerDetalle: () => _proximamente(context),
          ),
          ProductoCard(
            nombre: 'Capuchino',
            descripcion: 'Espresso con leche vaporizada y espuma cremosa.',
            precio: 2.50,
            icono: Icons.coffee_maker,
            onVerDetalle: () => _proximamente(context),
          ),
          ProductoCard(
            nombre: 'Cheesecake de fresa',
            descripcion: 'Porción de cheesecake con salsa de fresa natural.',
            precio: 3.25,
            icono: Icons.cake,
            onVerDetalle: () => _proximamente(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
