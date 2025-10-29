import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject<String?>();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          onNotificationClick.add(notificationResponse.payload);
        }
      },
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // For Android 13+ we'd use requestNotificationsPermission, but in older versions of the package
    // we can skip this since permissions are handled in the AndroidManifest.xml
    
    await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
  }) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId ?? 'greenhouse_channel',
      channelName ?? 'Greenhouse Alerts',
      channelDescription: channelDescription ?? 'Alerts from greenhouse monitoring system',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      color: channelId == 'critical_alerts' ? const Color(0xFFFF0000) : null,
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Show critical alert with high priority and special sound
  Future<void> showCriticalAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelId: 'critical_alerts',
      channelName: 'Critical Alerts',
      channelDescription: 'Urgent alerts requiring immediate attention',
    );
  }
}