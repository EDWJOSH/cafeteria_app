import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/theme/app_theme.dart';

/// Servicio nativo de notificaciones locales (Android Channels + iOS).
class NotificationService {
  /// Canal de alta importancia: confirmación de pedidos.
  static const canalPedidos = AndroidNotificationChannel(
    'pedidos',
    'Pedidos',
    description: 'Confirmación de los pedidos que haces en la app',
    importance: Importance.high,
  );

  /// Canal de importancia normal: cambios de conexión.
  static const canalConexion = AndroidNotificationChannel(
    'conectividad',
    'Estado de conexión',
    description: 'Avisos cuando se pierde o se recupera internet',
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  int _siguienteId = 0;

  bool get _soportado => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Configura el plugin y registra los canales en Android.
  Future<void> inicializar() async {
    if (!_soportado) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notificacion'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(canalPedidos);
    await android?.createNotificationChannel(canalConexion);
  }

  /// Android 13+ e iOS piden permiso en tiempo de ejecución para notificar.
  Future<bool> solicitarPermiso() async {
    if (!_soportado) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final concedido =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return concedido ?? false;
  }

  Future<void> mostrar(
    AndroidNotificationChannel canal,
    String titulo,
    String cuerpo,
  ) async {
    if (!_soportado) return;
    await _plugin.show(
      id: _siguienteId++,
      title: titulo,
      body: cuerpo,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          canal.id,
          canal.name,
          channelDescription: canal.description,
          importance: canal.importance,
          priority: canal.importance == Importance.high
              ? Priority.high
              : Priority.defaultPriority,
          color: AppColors.terracota,
          styleInformation: BigTextStyleInformation(cuerpo),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Eventos clave del sistema

  Future<void> pedidoConfirmado(String resumen) => mostrar(
    canalPedidos,
    'Pedido confirmado',
    '$resumen. Te avisaremos cuando esté listo.',
  );

  Future<void> conexionPerdida() => mostrar(
    canalConexion,
    'Estás sin conexión',
    'Puedes seguir viendo el menú guardado. Te avisaremos cuando vuelva internet.',
  );

  Future<void> conexionRecuperada() => mostrar(
    canalConexion,
    'Conexión restablecida',
    'Estamos actualizando el menú con los últimos productos.',
  );
}
