import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/clima.dart';

/// Error de red o de datos con un mensaje que se puede mostrar al usuario.
class ClimaException implements Exception {
  final String mensaje;

  const ClimaException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Capa de servicio: consume la API pública de Open-Meteo (sin token).
class ClimaApiService {
  /// Coordenadas del local en Guayaquil.
  static const latitud = -2.19;
  static const longitud = -79.89;

  static final Uri endpoint = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': '$latitud',
    'longitude': '$longitud',
    'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m',
    'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
    'timezone': 'America/Guayaquil',
    'forecast_days': '5',
  });

  final http.Client _cliente;

  ClimaApiService({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  /// Petición GET asíncrona. Convierte cada tipo de fallo en ClimaException.
  Future<Clima> obtenerClima() async {
    try {
      final respuesta = await _cliente
          .get(endpoint)
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode != 200) {
        throw ClimaException(
          'El servicio del clima respondió con error ${respuesta.statusCode}.',
        );
      }
      final json = jsonDecode(respuesta.body) as Map<String, dynamic>;
      return Clima.fromJson(json);
    } on SocketException {
      throw const ClimaException(
        'Sin conexión a internet. Revisa tu Wi-Fi o datos móviles.',
      );
    } on http.ClientException {
      throw const ClimaException(
        'No se pudo conectar con el servicio del clima.',
      );
    } on TimeoutException {
      throw const ClimaException(
        'El servicio del clima tardó demasiado en responder.',
      );
    } on FormatException {
      throw const ClimaException('La respuesta del clima llegó dañada.');
    } on TypeError {
      // El JSON no tiene la estructura esperada (campo faltante o de otro tipo).
      throw const ClimaException('La respuesta del clima llegó dañada.');
    }
  }
}
