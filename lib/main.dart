import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'providers/periodo_provider.dart';
import 'providers/faltas_provider.dart';
import 'providers/eventos_provider.dart';
import 'providers/settings_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize database
  await DatabaseService.instance.database;
  
  // Initialize notifications
  await NotificationService.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Sistema vai ajustar automaticamente baseado no tema
  // A cor da status bar será controlada pelo MaterialApp
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PeriodoProvider()),
        ChangeNotifierProvider(create: (_) => FaltasProvider()),
        ChangeNotifierProvider(create: (_) => EventosProvider()),
      ],
      child: const FaltaControlApp(),
    ),
  );
}
