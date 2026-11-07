import 'package:flutter/material.dart';

/// Condiciones actuales (objeto "current" del JSON de Open-Meteo).
class ClimaActual {
  final DateTime hora;
  final double temperatura;
  final double sensacionTermica;
  final int humedad;
  final double viento;
  final int codigoClima;

  const ClimaActual({
    required this.hora,
    required this.temperatura,
    required this.sensacionTermica,
    required this.humedad,
    required this.viento,
    required this.codigoClima,
  });

  factory ClimaActual.fromJson(Map<String, dynamic> json) => ClimaActual(
    hora: DateTime.parse(json['time'] as String),
    temperatura: (json['temperature_2m'] as num).toDouble(),
    sensacionTermica: (json['apparent_temperature'] as num).toDouble(),
    humedad: (json['relative_humidity_2m'] as num).toInt(),
    viento: (json['wind_speed_10m'] as num).toDouble(),
    codigoClima: (json['weather_code'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'time': hora.toIso8601String(),
    'temperature_2m': temperatura,
    'apparent_temperature': sensacionTermica,
    'relative_humidity_2m': humedad,
    'wind_speed_10m': viento,
    'weather_code': codigoClima,
  };
}

/// Pronóstico de un día (una posición de los arreglos de "daily").
class PronosticoDia {
  final DateTime fecha;
  final int codigoClima;
  final double maxima;
  final double minima;
  final int probabilidadLluvia;

  const PronosticoDia({
    required this.fecha,
    required this.codigoClima,
    required this.maxima,
    required this.minima,
    required this.probabilidadLluvia,
  });
}

/// Respuesta completa de la API: clima actual + pronóstico de varios días.
class Clima {
  final String zonaHoraria;
  final ClimaActual actual;
  final List<PronosticoDia> dias;

  const Clima({
    required this.zonaHoraria,
    required this.actual,
    required this.dias,
  });

  /// "daily" llega como arreglos paralelos (uno por campo); aquí se unen
  /// posición por posición para formar una lista de PronosticoDia.
  factory Clima.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>;
    final fechas = daily['time'] as List;
    final codigos = daily['weather_code'] as List;
    final maximas = daily['temperature_2m_max'] as List;
    final minimas = daily['temperature_2m_min'] as List;
    final lluvias = daily['precipitation_probability_max'] as List;

    return Clima(
      zonaHoraria: json['timezone'] as String,
      actual: ClimaActual.fromJson(json['current'] as Map<String, dynamic>),
      dias: [
        for (var i = 0; i < fechas.length; i++)
          PronosticoDia(
            fecha: DateTime.parse(fechas[i] as String),
            codigoClima: (codigos[i] as num).toInt(),
            maxima: (maximas[i] as num).toDouble(),
            minima: (minimas[i] as num).toDouble(),
            probabilidadLluvia: (lluvias[i] as num?)?.toInt() ?? 0,
          ),
      ],
    );
  }

  /// Vuelve a armar el JSON con la misma forma que entrega la API.
  Map<String, dynamic> toJson() => {
    'timezone': zonaHoraria,
    'current': actual.toJson(),
    'daily': {
      'time': [
        for (final d in dias) d.fecha.toIso8601String().substring(0, 10),
      ],
      'weather_code': [for (final d in dias) d.codigoClima],
      'temperature_2m_max': [for (final d in dias) d.maxima],
      'temperature_2m_min': [for (final d in dias) d.minima],
      'precipitation_probability_max': [
        for (final d in dias) d.probabilidadLluvia,
      ],
    },
  };
}

/// Traduce el código WMO de Open-Meteo a un texto y un ícono.
({String texto, IconData icono}) describirClima(int codigo) => switch (codigo) {
  0 => (texto: 'Despejado', icono: Icons.wb_sunny),
  1 || 2 => (texto: 'Parcialmente nublado', icono: Icons.wb_cloudy_outlined),
  3 => (texto: 'Nublado', icono: Icons.cloud),
  45 || 48 => (texto: 'Neblina', icono: Icons.foggy),
  >= 51 && <= 57 => (texto: 'Llovizna', icono: Icons.grain),
  >= 61 && <= 67 => (texto: 'Lluvia', icono: Icons.water_drop),
  >= 80 && <= 82 => (texto: 'Chubascos', icono: Icons.umbrella),
  >= 95 => (texto: 'Tormenta', icono: Icons.thunderstorm),
  _ => (texto: 'Variable', icono: Icons.cloud_queue),
};
