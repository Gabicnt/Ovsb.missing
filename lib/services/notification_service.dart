import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/constantes.dart';

/// Serviço de notificações locais
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Criar canal de notificação para Android
    await _createNotificationChannel();
  }

  /// Cria canal de notificação para Android 8+
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDesc,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Callback quando usuário toca na notificação
  void _onNotificationTap(NotificationResponse response) {
    // Navegar para tela específica baseado no payload
    print('Notificação clicada: ${response.payload}');
  }

  /// Mostra notificação imediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Agenda notificação para uma data/hora específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Agenda notificação de sugestão de descanso
  Future<void> scheduleSugestaoDescanso({
    required DateTime data,
    required int faltasDisponiveis,
    required int horario, // Hora do dia (0-23)
  }) async {
    final scheduledDate = DateTime(
      data.year,
      data.month,
      data.day - 1, // Um dia antes
      horario,
      0,
    );

    if (scheduledDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: AppConstants.notificationIdSugestao + data.hashCode,
        title: 'Sugestão de descanso',
        body: 'Amanhã (${_formatDate(data)}) é um ótimo dia para descansar. Faltas disponíveis: $faltasDisponiveis.',
        scheduledDate: scheduledDate,
        payload: 'sugestao:${data.toIso8601String()}',
      );
    }
  }

  /// Notificação de margem atingida
  Future<void> notifyMargemAtingida() async {
    await showNotification(
      id: AppConstants.notificationIdMargem,
      title: 'Margem de segurança atingida',
      body: 'Atenção: sua margem de segurança foi atingida. Use suas faltas com cautela.',
      payload: 'margem',
    );
  }

  /// Agenda notificação de dia importante
  Future<void> scheduleDiaImportante({
    required DateTime data,
    required String descricao,
    required int horario,
  }) async {
    final scheduledDate = DateTime(
      data.year,
      data.month,
      data.day - 1, // Um dia antes
      horario,
      0,
    );

    if (scheduledDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: AppConstants.notificationIdDiaImportante + data.hashCode,
        title: 'Dia importante amanhã',
        body: 'Amanhã: $descricao. Não falte!',
        scheduledDate: scheduledDate,
        payload: 'importante:${data.toIso8601String()}',
      );
    }
  }

  /// Cancela uma notificação específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}
