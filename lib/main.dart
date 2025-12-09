import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location & notification permissions
  await requestPermissions();

  // Initialize background service
  await initializeService();

  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  // Request location permission
  if (!await Permission.locationWhenInUse.isGranted) {
    await Permission.locationWhenInUse.request();
  }

  // Request notification permission (Android 13+)
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
