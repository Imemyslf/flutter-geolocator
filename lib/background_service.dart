// background_service.dart
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Timer? locationTimer;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'live_location_channel',
    'Live Location',
    description: 'Shows live location every 5 seconds',
    importance: Importance.max,
  );

  // Notification channel creation
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'live_location_channel',
      initialNotificationTitle: 'Live Location Tracker',
      initialNotificationContent: 'Tracking your location...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // 🚫 Stop tracking trigger
  service.on('STOP_TRACKING').listen((event) {
    locationTimer?.cancel();
    service.stopSelf();
  });

  // ▶ Start periodic location updates
  locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await flutterLocalNotificationsPlugin.show(
        999,
        'Live Location',
        'Lat: ${pos.latitude}, Lng: ${pos.longitude}',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'live_location_channel',
            'Live Location',
            channelDescription: 'Shows live location every 5 seconds',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            actions: [
              AndroidNotificationAction(
                'STOP_TRACKING',
                'Stop Tracking',
                showsUserInterface: false,
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print("Location error: $e");
    }
  });
}
