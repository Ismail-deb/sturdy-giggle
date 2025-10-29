import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
// Import timezone package for scheduling notifications
import 'package:timezone/data/latest.dart' as tz;

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
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Setup Android notification settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Setup iOS notification settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // Combine platform-specific settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // Initialize with settings
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
      debugPrint('NotificationService: Successfully initialized');
    } catch (e) {
      debugPrint('NotificationService: Error initializing - $e');
    }
  }

  Future<void> _requestPermissions() async {
    // For iOS request permissions
    final iosImplementation = 
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
            
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
  }) async {
    try {
      // Configure Android-specific notification details
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId ?? 'greenhouse_channel',
        channelName ?? 'Greenhouse Alerts',
        channelDescription: channelDescription ?? 'Alerts from greenhouse monitoring system',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
        color: channelId == 'critical_alerts' ? const Color(0xFFFF0000) : null,
      );
      
      // Configure iOS-specific notification details
      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      // Combine platform-specific details
      NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      // Show the notification
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
      
      // Track click events
      if (payload != null) {
        onNotificationClick.add(payload);
      }
    } catch (e) {
      debugPrint('NotificationService: Error showing notification - $e');
    }
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