import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showTemperatureAlert(double temperature, String status) async {
    String title;
    String body;

    if (temperature < 2.0) {
      title = 'Temperature Too Low!';
      body = 'Current temperature is ${temperature.toStringAsFixed(1)}°C. Please check the storage conditions.';
    } else if (temperature > 8.0) {
      title = 'Temperature Too High!';
      body = 'Current temperature is ${temperature.toStringAsFixed(1)}°C. Please check the storage conditions.';
    } else {
      return; // Don't show notification for normal temperatures
    }

    const androidDetails = AndroidNotificationDetails(
      'temperature_alerts',
      'Temperature Alerts',
      channelDescription: 'Notifications for temperature alerts',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.red,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
    );
  }
} 