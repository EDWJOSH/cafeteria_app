import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formato.dart';
import '../data/catalogo_repository.dart';
import '../providers/catalogo_provider.dart';
import '../providers/conectividad_provider.dart';
import '../services/connectivity_service.dart';

/// Banner que aparece arriba cuando no hay internet y explica qué datos se muestran.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final conexion = context.watch<ConectividadProvider>();
    final catalogo = context.watch<CatalogoProvider>();
    final visible = conexion.verificado && !conexion.enLinea;

    final titulo = conexion.estado == EstadoRed.sinInternet
        ? 'Conectado, pero sin acceso a internet'
        : 'Sin conexión a internet';
    final detalle = switch (catalogo.origen) {
      OrigenCatalogo.red || OrigenCatalogo.cache =>
        'Mostrando el menú guardado el ${formatearFecha(catalogo.actualizado!)}',
      _ => 'Mostrando el menú básico incluido en la app',
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Material(
              color: AppColors.espresso,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: AppColors.crema),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              color: AppColors.crema,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            detalle,
                            style: const TextStyle(
                              color: AppColors.arena,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: conexion.reintentar,
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(color: AppColors.crema),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
