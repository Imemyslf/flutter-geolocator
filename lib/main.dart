// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init notifications with action handlers
  await initNotificationActions();

  await requestPermissions();
  await initializeService();

  runApp(const MyApp());
}

Future<void> initNotificationActions() async {
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.actionId == 'STOP_TRACKING') {
        FlutterBackgroundService().invoke('STOP_TRACKING');
      }
    },
  );
}

Future<void> requestPermissions() async {
  if (!await Permission.locationWhenInUse.isGranted) {
    await Permission.locationWhenInUse.request();
  }

  if (!await Permission.notification.isGranted) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location Tracker',
      home: Scaffold(
        appBar: AppBar(title: const Text('Tracker')),
        body: const Center(
          child: Text('Tracking live location in background...'),
        ),
      ),
    );
  }
}
