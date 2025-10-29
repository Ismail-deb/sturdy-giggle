import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/alert_notification.dart';
import '../../services/notification_service.dart';
import '../../services/api_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  final NotificationService _notificationService = NotificationService();
  Timer? _pollingTimer;
  List<AlertNotification> _notificationHistory = [];
  final List<String> _processedAlertIds = [];
  
  factory NotificationManager() {
    return _instance;
  }
  
  NotificationManager._internal();
  
  List<AlertNotification> get notificationHistory => List.unmodifiable(_notificationHistory);
  
  // Start polling for alerts from the server
  void startAlertPolling() {
    // Stop any existing timer
    _pollingTimer?.cancel();
    
    // Load notification history from storage
    _loadNotificationHistory();
    
    // Check alerts immediately
    _checkForAlerts();
    
    // Set up periodic alert checking
    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkForAlerts();
    });
  }
  
  // Stop polling for alerts
  void stopAlertPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  // Check for new alerts from the server
  Future<void> _checkForAlerts() async {
    try {
      final response = await ApiService.getAlerts();
      final alerts = response;
      
      for (var alert in alerts) {
        // Generate a unique ID for this alert
        final alertData = alert as Map<String, dynamic>;
        final alertId = "${alertData['sensor_type']}_${alertData['timestamp']}";
        
        // Check if we've already processed this alert
        if (!_processedAlertIds.contains(alertId)) {
          // Add to processed list
          _processedAlertIds.add(alertId);
          
          // Create notification object
          final notification = AlertNotification.fromJson({
            ...alertData,
            'id': alertId,
          });
          
          // Add to history
          _addToHistory(notification);
          
          // Show notification to user
          if (notification.severity == 'critical') {
            await _notificationService.showCriticalAlert(
              id: notification.hashCode,
              title: notification.title,
              body: notification.message,
              payload: notification.sensorType,
            );
          } else if (notification.severity == 'high') {
            await _notificationService.showNotification(
              id: notification.hashCode,
              title: notification.title,
              body: notification.message,
              payload: notification.sensorType,
            );
          }
        }
      }
      
      // Keep the processed ID list manageable
      if (_processedAlertIds.length > 100) {
        _processedAlertIds.removeRange(0, 50);
      }
    } catch (e) {
      debugPrint('Error checking for alerts: $e');
    }
  }
  
  // Add notification to history and save
  void _addToHistory(AlertNotification notification) {
    _notificationHistory.insert(0, notification);
    
    // Keep history at reasonable size
    if (_notificationHistory.length > 50) {
      _notificationHistory.removeLast();
    }
    
    _saveNotificationHistory();
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notificationHistory.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notificationHistory[index] = _notificationHistory[index].copyWith(isRead: true);
      await _saveNotificationHistory();
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notificationHistory = _notificationHistory.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotificationHistory();
  }
  
  // Save notification history to local storage
  Future<void> _saveNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = _notificationHistory.map((n) => n.toJson()).toList();
      await prefs.setString('notification_history', jsonEncode(jsonData));
    } catch (e) {
      debugPrint('Error saving notification history: $e');
    }
  }
  
  // Load notification history from local storage
  Future<void> _loadNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('notification_history');
      
      if (historyJson != null) {
        final jsonData = jsonDecode(historyJson) as List<dynamic>;
        _notificationHistory = jsonData
            .map((item) => AlertNotification.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading notification history: $e');
    }
  }
  
  // Clear all notification history
  Future<void> clearHistory() async {
    _notificationHistory.clear();
    await _saveNotificationHistory();
  }
}