import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formato.dart';
import '../providers/perfil_provider.dart';
import '../services/media_service.dart';

/// Pantalla 3: foto de perfil del cliente (cámara o galería).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<void> _cambiarFoto(BuildContext context, ImageSource fuente) async {
    final perfil = context.read<PerfilProvider>();
    final estado = await perfil.cambiarFoto(fuente);
    if (!context.mounted) return;

    switch (estado) {
      case EstadoPermiso.concedido:
        if (perfil.error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(perfil.error!)));
        }
      case EstadoPermiso.denegado:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sin permiso no podemos usar la cámara. Puedes intentarlo otra vez.',
            ),
          ),
        );
      case EstadoPermiso.denegadoPermanente:
        await _mostrarDialogoAjustes(context);
    }
  }

  /// Si el permiso quedó bloqueado, solo se puede activar desde los ajustes del sistema.
  Future<void> _mostrarDialogoAjustes(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.no_photography_outlined),
        title: const Text('Permiso de cámara bloqueado'),
        content: const Text(
          'Rechazaste el permiso de cámara y Android ya no vuelve a preguntar. '
          'Para tomar tu foto, actívalo en Ajustes > Permisos > Cámara.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PerfilProvider>().abrirAjustes();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilProvider>();
    final textos = Theme.of(context).textTheme;
    final resultado = perfil.ultimoResultado;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: AppColors.arena,
                  foregroundImage: perfil.foto != null
                      ? FileImage(perfil.foto!)
                      : null,
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: AppColors.espresso,
                  ),
                ),
                if (perfil.procesando) const CircularProgressIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu foto de cliente',
            style: textos.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Aparece en tus pedidos para que el barista te reconozca.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: perfil.procesando
                ? null
                : () => _cambiarFoto(context, ImageSource.camera),
            icon: const Icon(Icons.photo_camera),
            label: const Text('Tomar foto'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: perfil.procesando
                ? null
                : () => _cambiarFoto(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Elegir de la galería'),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.compress, color: AppColors.oliva),
                title: const Text('Imagen recortada y comprimida'),
                subtitle: Text(
                  'Original: ${formatearBytes(resultado.bytesOriginal)}  →  '
                  'Final: ${formatearBytes(resultado.bytesFinal)} '
                  '(-${resultado.ahorroPorcentaje}%)',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
