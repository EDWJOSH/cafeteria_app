import 'package:flutter/material.dart';

/// Pequeño recuadro con un ícono y un texto (horario, ubicación, etc.).
class InfoChip extends StatelessWidget {
  final IconData icono;
  final String texto;

  const InfoChip({super.key, required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colores.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 18, color: colores.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(color: colores.onSecondaryContainer)),
        ],
      ),
    );
  }
}
