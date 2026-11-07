import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/clima.dart';
import '../models/producto.dart';
import '../providers/catalogo_provider.dart';
import '../providers/clima_provider.dart';
import '../providers/pedido_provider.dart';
import 'detalle_screen.dart';

/// Pantalla 4: clima de Guayaquil (API Open-Meteo) y bebidas recomendadas.
class ClimaScreen extends StatefulWidget {
  const ClimaScreen({super.key});

  @override
  State<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends State<ClimaScreen> {
  @override
  void initState() {
    super.initState();
    // La primera vez que se abre la pantalla se piden los datos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clima = context.read<ClimaProvider>();
      if (clima.estado == EstadoClima.inicial) clima.cargar();
    });
  }

  Future<void> _pedir(Producto producto) async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => DetalleScreen(producto: producto)),
    );
    if (!mounted || resultado == null) return;
    final pedidos = context.read<PedidoProvider>();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Pedido registrado: $resultado')));
    await pedidos.registrar(resultado);
  }

  @override
  Widget build(BuildContext context) {
    final clima = context.watch<ClimaProvider>();

    // Se elige qué mostrar según el estado de la petición.
    final Widget cuerpo = switch (clima.estado) {
      EstadoClima.inicial ||
      EstadoClima.cargando when clima.clima == null => const _VistaCargando(),
      EstadoClima.error => _VistaError(
        mensaje: clima.mensajeError!,
        onReintentar: clima.cargar,
      ),
      _ => _VistaDatos(clima: clima, onPedir: _pedir),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Clima y antojo')),
      body: RefreshIndicator(onRefresh: clima.cargar, child: cuerpo),
    );
  }
}

/// Estado "Cargando".
class _VistaCargando extends StatelessWidget {
  const _VistaCargando();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 20),
        Text(
          'Consultando el clima en Guayaquil...',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Text(
          'Fuente: Open-Meteo',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.oliva, fontSize: 12),
        ),
      ],
    );
  }
}

/// Estado "Error de conexión".
class _VistaError extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onReintentar;

  const _VistaError({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    // ListView para que también funcione el pull-to-refresh en el error.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.cloud_off, size: 72, color: AppColors.terracota),
        const SizedBox(height: 16),
        Text(
          'No pudimos cargar el clima',
          style: textos.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(mensaje, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Center(
          child: FilledButton.icon(
            onPressed: onReintentar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'o desliza hacia abajo para volver a intentarlo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// Estado "Éxito con datos".
class _VistaDatos extends StatelessWidget {
  final ClimaProvider clima;
  final Future<void> Function(Producto) onPedir;

  const _VistaDatos({required this.clima, required this.onPedir});

  @override
  Widget build(BuildContext context) {
    final datos = clima.clima!;
    final textos = Theme.of(context).textTheme;
    final categoria = clima.haceCalor ? 'Bebidas frías' : 'Bebidas calientes';
    final recomendados = context
        .watch<CatalogoProvider>()
        .productos
        .where((p) => p.categoria == categoria)
        .toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (clima.estado == EstadoClima.cargando)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(),
          ),
        _TarjetaActual(actual: datos.actual),
        const SizedBox(height: 12),
        Card(
          color: clima.haceCalor ? AppColors.salvia : AppColors.arena,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clima.haceCalor
                      ? 'Hace calor: te recomendamos algo frío'
                      : 'Clima fresco: te recomendamos algo caliente',
                  style: textos.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (final producto in recomendados)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(producto.icono, color: AppColors.espresso),
                    title: Text(producto.nombre),
                    subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                    trailing: FilledButton(
                      onPressed: () => onPedir(producto),
                      child: const Text('Pedir'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Próximos días', style: textos.titleLarge),
        const SizedBox(height: 4),
        for (final dia in datos.dias) _TarjetaDia(dia: dia),
        const SizedBox(height: 12),
        const Text(
          'Datos del clima: Open-Meteo.com (CC BY 4.0) · Desliza hacia abajo para actualizar',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.oliva),
        ),
      ],
    );
  }
}

class _TarjetaActual extends StatelessWidget {
  final ClimaActual actual;

  const _TarjetaActual({required this.actual});

  @override
  Widget build(BuildContext context) {
    final desc = describirClima(actual.codigoClima);
    String dos(int n) => n.toString().padLeft(2, '0');

    return Card(
      color: AppColors.espresso,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guayaquil, ahora',
              style: TextStyle(color: AppColors.arena),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(desc.icono, size: 56, color: AppColors.crema),
                const SizedBox(width: 16),
                // FittedBox reduce el número en pantallas angostas.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${actual.temperatura.toStringAsFixed(1)} °C',
                      style: const TextStyle(
                        fontFamily: AppTheme.fuenteTitulos,
                        fontSize: 44,
                        color: AppColors.crema,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              desc.texto,
              style: const TextStyle(color: AppColors.crema, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _Dato(
                  Icons.thermostat,
                  'Sensación ${actual.sensacionTermica.toStringAsFixed(0)} °C',
                ),
                _Dato(Icons.water_drop_outlined, 'Humedad ${actual.humedad} %'),
                _Dato(Icons.air, 'Viento ${actual.viento} km/h'),
                _Dato(
                  Icons.schedule,
                  'Medición ${dos(actual.hora.hour)}:${dos(actual.hora.minute)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato(this.icono, this.texto);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: AppColors.arena),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(color: AppColors.arena)),
      ],
    );
  }
}

class _TarjetaDia extends StatelessWidget {
  final PronosticoDia dia;

  const _TarjetaDia({required this.dia});

  static const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  String get _nombreDia {
    final hoy = DateTime.now();
    final diferencia = DateTime(
      dia.fecha.year,
      dia.fecha.month,
      dia.fecha.day,
    ).difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Mañana';
    return '${_dias[dia.fecha.weekday - 1]} ${dia.fecha.day}';
  }

  @override
  Widget build(BuildContext context) {
    final desc = describirClima(dia.codigoClima);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(desc.icono, color: AppColors.terracota, size: 32),
        title: Text(
          _nombreDia,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${desc.texto} · lluvia ${dia.probabilidadLluvia} %'),
        trailing: Text(
          '${dia.maxima.round()}° / ${dia.minima.round()}°',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
