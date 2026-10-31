import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/formato.dart';
import '../data/catalogo_repository.dart';
import '../models/producto.dart';
import '../providers/catalogo_provider.dart';
import '../widgets/info_chip.dart';
import '../widgets/offline_banner.dart';
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Pedido registrado: $resultado')));
  }

  /// Explica al usuario de dónde vienen los productos que está viendo.
  String _textoOrigen(CatalogoProvider catalogo) {
    if (catalogo.cargando) return 'Actualizando menú...';
    return switch (catalogo.origen) {
      OrigenCatalogo.red =>
        'Menú actualizado desde internet · ${formatearFecha(catalogo.actualizado!)}',
      OrigenCatalogo.cache =>
        'Menú guardado en el equipo · ${formatearFecha(catalogo.actualizado!)}',
      OrigenCatalogo.local => 'Menú básico (sin datos descargados)',
      null => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;
    final catalogo = context.watch<CatalogoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_outlined),
            SizedBox(width: 8),
            Text('Grano & Co.'),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: catalogo.cargar,
              child: ListView(
                children: [
                  Image.asset(
                    'assets/images/banner.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: 'Banner de Grano & Co.',
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido a Grano & Co.',
                          style: textos.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Café de especialidad, tostado aquí mismo. Elige y haz tu pedido.',
                        ),
                        const SizedBox(height: 12),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InfoChip(
                              icono: Icons.schedule,
                              texto: 'Lun a Sáb, 7:00 - 20:00',
                            ),
                            InfoChip(
                              icono: Icons.location_on,
                              texto: 'Guayaquil, Ecuador',
                            ),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                    child: Text(
                      _textoOrigen(catalogo),
                      style: textos.bodySmall?.copyWith(
                        color: colores.secondary,
                      ),
                    ),
                  ),
                  if (catalogo.cargando && catalogo.productos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  for (final producto in catalogo.productos)
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
            ),
          ),
        ],
      ),
    );
  }
}
