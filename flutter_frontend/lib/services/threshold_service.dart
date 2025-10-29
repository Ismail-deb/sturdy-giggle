import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThresholdService {
  static final ThresholdService _instance = ThresholdService._internal();
  factory ThresholdService() => _instance;
  ThresholdService._internal();

  Map<String, dynamic>? _cachedThresholds;

  /// Get default thresholds based on THRESHOLDS.md
  Map<String, dynamic> getDefaultThresholds() {
    return {
      'temperature': {
        'optimal': {'min': 20, 'max': 27},
        'acceptable': {'min': 18, 'max': 30},
      },
      'humidity': {
        'optimal': {'min': 45, 'max': 70},
        'acceptable': {'min': 71, 'max': 80},
      },
      'mq135': {
        'good': 200,
        'poor': 500,
      },
      'mq2': {
        'safe': 300,
        'high': 750,
      },
      'mq7': {
        'safe': 300,
        'high': 750,
      },
    };
  }

  /// Load thresholds from SharedPreferences or return defaults
  Future<Map<String, dynamic>> loadThresholds() async {
    if (_cachedThresholds != null) {
      return _cachedThresholds!;
    }

    final prefs = await SharedPreferences.getInstance();
    final thresholdsJson = prefs.getString('sensor_thresholds');

    if (thresholdsJson != null) {
      _cachedThresholds = jsonDecode(thresholdsJson);
    } else {
      _cachedThresholds = getDefaultThresholds();
    }

    return _cachedThresholds!;
  }

  /// Clear cached thresholds (call after saving new values)
  void clearCache() {
    _cachedThresholds = null;
  }

  /// Get temperature status based on current thresholds
  Future<String> getTemperatureStatus(double temperature) async {
    final thresholds = await loadThresholds();
    final optimal = thresholds['temperature']['optimal'];
    final acceptable = thresholds['temperature']['acceptable'];

    if (temperature >= optimal['min'] && temperature <= optimal['max']) {
      return 'Optimal';
    } else if (temperature >= acceptable['min'] && temperature <= acceptable['max']) {
      return 'Acceptable';
    } else {
      return 'Critical';
    }
  }

  /// Get humidity status based on current thresholds
  Future<String> getHumidityStatus(double humidity) async {
    final thresholds = await loadThresholds();
    final optimal = thresholds['humidity']['optimal'];
    final acceptable = thresholds['humidity']['acceptable'];

    if (humidity >= optimal['min'] && humidity <= optimal['max']) {
      return 'Optimal';
    } else if (humidity >= acceptable['min'] && humidity <= acceptable['max']) {
      return 'Acceptable';
    } else {
      return 'Critical';
    }
  }

  /// Get MQ135 (Air Quality) status based on current thresholds
  Future<String> getMQ135Status(double value) async {
    final thresholds = await loadThresholds();
    final good = thresholds['mq135']['good'];
    final poor = thresholds['mq135']['poor'];

    if (value <= good) {
      return 'Good';
    } else if (value <= poor) {
      return 'Moderate';
    } else {
      return 'Poor';
    }
  }

  /// Get MQ2 (Flammable Gas) status based on current thresholds
  Future<String> getMQ2Status(double value) async {
    final thresholds = await loadThresholds();
    final safe = thresholds['mq2']['safe'];
    final high = thresholds['mq2']['high'];

    if (value <= safe) {
      return 'Safe';
    } else if (value <= high) {
      return 'Elevated';
    } else {
      return 'High';
    }
  }

  /// Get MQ7 (Carbon Monoxide) status based on current thresholds
  Future<String> getMQ7Status(double value) async {
    final thresholds = await loadThresholds();
    final safe = thresholds['mq7']['safe'];
    final high = thresholds['mq7']['high'];

    if (value <= safe) {
      return 'Safe';
    } else if (value <= high) {
      return 'Elevated';
    } else {
      return 'High';
    }
  }

  /// Get status color based on status string
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
      case 'safe':
        return const Color(0xFF4CAF50); // Green
      case 'acceptable':
      case 'moderate':
      case 'elevated':
        return const Color(0xFFFFA726); // Orange
      case 'critical':
      case 'poor':
      case 'high':
        return const Color(0xFFE53935); // Red
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }
}
