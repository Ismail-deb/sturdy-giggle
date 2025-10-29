import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../screens/sensor_analysis_screen.dart';

class SensorDetailHelper {
  // Show the sensor details and analysis screen
  static void showSensorDetails(BuildContext context, String sensorType, SensorData data) {
    // Navigate to the sensor analysis screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SensorAnalysisScreen(sensorType: sensorType),
      ),
    );
  }
}