import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../widgets/info_chip.dart';
import '../widgets/producto_card.dart';
import 'detalle_screen.dart';

/// Pantalla 1: muestra el banner, la información del local y el menú.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _ultimoPedido;

  /// Abre la Pantalla 2 enviando el producto elegido y espera la respuesta.
  Future<void> _abrirDetalle(Producto producto) async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleScreen(producto: producto),
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() => _ultimoPedido = resultado);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pedido registrado: $resultado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Café Aroma'),
        centerTitle: true,
        backgroundColor: colores.primaryContainer,
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
          if (_ultimoPedido != null)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: colores.tertiaryContainer,
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Último pedido'),
                subtitle: Text(_ultimoPedido!),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('Nuestro menú', style: textos.titleLarge),
          ),
          for (final producto in catalogo)
            ProductoCard(
              nombre: producto.nombre,
              descripcion: producto.descripcion,
              precio: producto.precio,
              icono: producto.icono,
              onVerDetalle: () => _abrirDetalle(producto),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
