import 'package:flutter/material.dart';

import '../models/producto.dart';

/// Pantalla 2: detalle del producto y formulario para pedirlo.
class DetalleScreen extends StatefulWidget {
  final Producto producto;

  const DetalleScreen({super.key, required this.producto});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  int _cantidad = 1;
  String _tamano = 'Mediano';

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  /// Valida el formulario y regresa a la Pantalla 1 con el resumen del pedido.
  void _confirmarPedido() {
    if (!_formKey.currentState!.validate()) return;

    final total = widget.producto.precio * _cantidad;
    final resumen =
        '${_nombreController.text.trim()} pidió $_cantidad x '
        '${widget.producto.nombre} ($_tamano) - Total \$${total.toStringAsFixed(2)}';

    Navigator.pop(context, resumen);
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final total = producto.precio * _cantidad;

    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colores.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Parámetro recibido desde Home: producto #${producto.id} - ${producto.nombre}',
                style: TextStyle(color: colores.onTertiaryContainer),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colores.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  producto.icono,
                  size: 64,
                  color: colores.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(producto.nombre, style: textos.headlineSmall),
            Text(
              producto.categoria,
              style: textos.labelLarge?.copyWith(color: colores.secondary),
            ),
            const SizedBox(height: 8),
            Text(producto.descripcion),
            const SizedBox(height: 8),
            Text(
              'Precio: \$${producto.precio.toStringAsFixed(2)}',
              style: textos.titleMedium?.copyWith(color: colores.primary),
            ),
            const Divider(height: 32),
            Text('Haz tu pedido', style: textos.titleLarge),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Tu nombre',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Escribe tu nombre para el pedido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _tamano,
                    decoration: const InputDecoration(
                      labelText: 'Tamaño',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Pequeño',
                        child: Text('Pequeño'),
                      ),
                      DropdownMenuItem(
                        value: 'Mediano',
                        child: Text('Mediano'),
                      ),
                      DropdownMenuItem(value: 'Grande', child: Text('Grande')),
                    ],
                    onChanged: (valor) => setState(() => _tamano = valor!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Cantidad'),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Quitar uno',
                        onPressed: _cantidad > 1
                            ? () => setState(() => _cantidad--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_cantidad', style: textos.titleMedium),
                      IconButton(
                        tooltip: 'Agregar uno',
                        onPressed: () => setState(() => _cantidad++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: textos.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _confirmarPedido,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar pedido'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver al menú'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
