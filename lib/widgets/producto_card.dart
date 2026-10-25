import 'package:flutter/material.dart';

/// Tarjeta reutilizable que muestra un producto del menú.
class ProductoCard extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final double precio;
  final IconData icono;
  final VoidCallback onVerDetalle;

  const ProductoCard({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.icono,
    required this.onVerDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colores.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, size: 30, color: colores.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '\$${precio.toStringAsFixed(2)}',
                    style: textos.titleSmall?.copyWith(
                      color: colores.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onVerDetalle,
              child: const Text('Ver'),
            ),
          ],
        ),
      ),
    );
  }
}
