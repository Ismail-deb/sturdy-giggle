import 'package:flutter/foundation.dart';

class DataPoint {
  final double value;
  final double timestamp;
  
  DataPoint({required this.value, required this.timestamp});
  
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
  
  factory DataPoint.fromJson(Map<String, dynamic> json) {
    // Ensure the value is properly converted to double regardless of input type
    double parseValue(dynamic val) {
      if (val == null) return 0.0;
      if (val is int) return val.toDouble();
      if (val is double) return val;
      if (val is String) {
        try {
          return double.parse(val);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }
    
    return DataPoint(
      value: parseValue(json['value']),
      timestamp: parseValue(json['timestamp']),
    );
  }
}

class SensorAnalysis {
  final String sensorType;
  final dynamic currentValue;
  final String unit;
  final String status;
  final List<DataPoint> historicalData;
  final String timeRange;
  final String analysis;
  final double timestamp;
  final Map<String, dynamic>? rawData;

  SensorAnalysis({
    required this.sensorType,
    required this.currentValue,
    required this.unit,
    required this.status,
    required this.historicalData,
    required this.timeRange,
    required this.analysis,
    required this.timestamp,
    this.rawData,
  });

  factory SensorAnalysis.fromJson(Map<String, dynamic> json) {
    // Helper to ensure valid double conversion
    double safeToDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) {
        try {
          return double.parse(value);
        } catch (_) {
          return 0.0;
        }
      }
      return 0.0;
    }
    
    // Handle both old and new formats for historical data
    List<DataPoint> parsedHistoricalData = [];
    
    if (json['historical_data'] is List) {
      final historicalData = json['historical_data'] as List;
      
      if (historicalData.isEmpty) {
        parsedHistoricalData = [];
      } else if (historicalData[0] is Map) {
        // New format: list of objects with value and timestamp
        try {
          parsedHistoricalData = historicalData
              .map((item) => DataPoint.fromJson(item as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint('Error parsing historical data: $e');
          // Provide at least two dummy points so chart doesn't crash
          final now = (json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch / 1000).toDouble();
          parsedHistoricalData = [
            DataPoint(value: 0, timestamp: now - 3600),
            DataPoint(value: 0, timestamp: now),
          ];
        }
      } else {
        // Old format: list of simple values
        final double now = safeToDouble(json['timestamp']);
        
        // Create data points with fake timestamps (one hour apart)
        try {
          parsedHistoricalData = historicalData.asMap().entries.map((entry) {
            final index = entry.key;
            final rawValue = entry.value;
            final value = safeToDouble(rawValue);
            final timestamp = now - (index * 3600); // One hour between points
            return DataPoint(value: value, timestamp: timestamp);
          }).toList();
          
          // If we have no valid data points, add dummy points
          if (parsedHistoricalData.isEmpty) {
            parsedHistoricalData = [
              DataPoint(value: 0, timestamp: now - 3600),
              DataPoint(value: 0, timestamp: now),
            ];
          }
        } catch (e) {
          debugPrint('Error creating historical data points: $e');
          // Fallback to dummy data
          parsedHistoricalData = [
            DataPoint(value: 0, timestamp: now - 3600),
            DataPoint(value: 0, timestamp: now),
          ];
        }
      }
    } else {
      // No historical data at all, create dummy data
      final now = (json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch / 1000).toDouble();
      parsedHistoricalData = [
        DataPoint(value: 0, timestamp: now - 3600),
        DataPoint(value: 0, timestamp: now),
      ];
    }

    return SensorAnalysis(
      sensorType: json['sensor_type'],
      currentValue: json['current_value'],
      unit: json['unit'],
      status: json['status'],
      historicalData: parsedHistoricalData,
      timeRange: json['time_range'] ?? 'hours',
      analysis: json['analysis'],
      timestamp: json['timestamp'].toDouble(),
      rawData: json['raw_data'],
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(
      (timestamp * 1000).toInt());

  // Helper method to get a color based on status
  String getFormattedStatus() {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
        return 'Optimal';
      case 'acceptable':
      case 'moderate':
      case 'adequate':
        return 'Acceptable';
      case 'critical':
      case 'poor':
      case 'insufficient':
        return 'Critical';
      case 'detected':
        return 'Detected';
      case 'none':
        return 'None Detected';
      case 'elevated':
        return 'Elevated';
      case 'high':
        return 'High';
      case 'safe':
        return 'Safe';
      // Light sensor statuses
      case 'bright':
        return 'Bright';
      case 'dim indoor':
        return 'Dim Indoor';
      case 'low light':
        return 'Low Light';
      case 'dark night':
        return 'Dark Night';
      default:
        return status;
    }
  }
}