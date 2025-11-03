import 'package:flutter/material.dart';

class SensorData {
  // Main dashboard readings
  final double temperature;
  final double humidity;
  final double co2Level;
  final double light;
  final double pressure;
  final double altitude;
  final double soilMoisture;
  final DateTime timestamp;
  
  // Detailed sensor readings
  final double temperatureBmp280;
  final double temperatureDht22;
  final double flameRaw;
  final bool flameDetected;
  final double lightRaw;
  
  // Gas sensors with baseline and drop values
  final double mq135Raw;
  final double mq135Baseline;
  final double mq135Drop;
  final String airQuality;
  
  final double mq2Raw;
  final double mq2Baseline;
  final double mq2Drop;
  final String smokeLevel;
  
  final double mq7Raw;
  final double mq7Baseline;
  final double mq7Drop;
  final String coLevel;
  
  // Combined wildcards
  final Map<String, dynamic>? co2AirQuality;
  final Map<String, dynamic>? pressureAltitude;
  
  // System info
  final int readingId;

  SensorData({
    // Main dashboard readings
    required this.temperature,
    required this.humidity,
    required this.co2Level,
    required this.light,
    required this.pressure,
    required this.altitude,
    required this.soilMoisture,
    required this.timestamp,
    
    // Detailed sensor readings
    required this.temperatureBmp280,
    required this.temperatureDht22,
    required this.flameRaw,
    required this.flameDetected,
    required this.lightRaw,
    
    // Gas sensors with baseline and drop values
    required this.mq135Raw,
    required this.mq135Baseline,
    required this.mq135Drop,
    required this.airQuality,
    
    required this.mq2Raw,
    required this.mq2Baseline,
    required this.mq2Drop,
    required this.smokeLevel,
    
    required this.mq7Raw,
    required this.mq7Baseline,
    required this.mq7Drop,
    required this.coLevel,
    
    // Combined wildcards
    this.co2AirQuality,
    this.pressureAltitude,
    
    // System info
    required this.readingId,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    // Process combined wildcards
    Map<String, dynamic>? co2AirQuality;
    Map<String, dynamic>? pressureAltitude;
    
    if (json['co2_air_quality'] != null) {
      co2AirQuality = json['co2_air_quality'] as Map<String, dynamic>;
    }
    
    if (json['pressure_altitude'] != null) {
      pressureAltitude = json['pressure_altitude'] as Map<String, dynamic>;
    }
    
    return SensorData(
      // Main dashboard readings
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      co2Level: json['co2_level']?.toDouble() ?? 0.0,
      light: json['light']?.toDouble() ?? 0.0,
      pressure: json['pressure']?.toDouble() ?? 0.0,
      altitude: json['altitude']?.toDouble() ?? 0.0,
  // Prefer sloi_moisture (external data source) if available, otherwise fall back to soil_moisture
  soilMoisture: (json['sloi_moisture'] ?? json['soil_moisture'])?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['timestamp'] * 1000).round()) 
          : DateTime.now(),
      
      // Detailed sensor readings
      temperatureBmp280: json['temperature_bmp280']?.toDouble() ?? 0.0,
      temperatureDht22: json['temperature_dht22']?.toDouble() ?? 0.0,
      flameRaw: json['flame_raw']?.toDouble() ?? 0.0,
      flameDetected: json['flame_detected'] ?? false,
      lightRaw: json['light_raw']?.toDouble() ?? 0.0,
      
      // Combined wildcards
      co2AirQuality: co2AirQuality,
      pressureAltitude: pressureAltitude,
      
      // Gas sensors with baseline and drop values
      mq135Raw: json['mq135_raw']?.toDouble() ?? 0.0,
      mq135Baseline: json['mq135_baseline']?.toDouble() ?? 0.0,
      mq135Drop: json['mq135_drop']?.toDouble() ?? 0.0,
      airQuality: json['air_quality'] ?? 'Unknown',
      
      mq2Raw: json['mq2_raw']?.toDouble() ?? 0.0,
      mq2Baseline: json['mq2_baseline']?.toDouble() ?? 0.0,
      mq2Drop: json['mq2_drop']?.toDouble() ?? 0.0,
      smokeLevel: json['smoke_level'] ?? 'Unknown',
      
      mq7Raw: json['mq7_raw']?.toDouble() ?? 0.0,
      mq7Baseline: json['mq7_baseline']?.toDouble() ?? 0.0,
      mq7Drop: json['mq7_drop']?.toDouble() ?? 0.0,
      coLevel: json['co_level'] ?? 'Unknown',
      
      // System info
      readingId: json['reading_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      // Main dashboard readings
      'temperature': temperature,
      'humidity': humidity,
      'co2_level': co2Level,
      'light': light,
      'pressure': pressure,
      'altitude': altitude,
      'soil_moisture': soilMoisture,
      'timestamp': timestamp.millisecondsSinceEpoch / 1000.0,
      
      // Detailed sensor readings
      'temperature_bmp280': temperatureBmp280,
      'temperature_dht22': temperatureDht22,
      'flame_raw': flameRaw,
      'flame_detected': flameDetected,
      'light_raw': lightRaw,
      
      // Gas sensors with baseline and drop values
      'mq135_raw': mq135Raw,
      'mq135_baseline': mq135Baseline,
      'mq135_drop': mq135Drop,
      'air_quality': airQuality,
      
      'mq2_raw': mq2Raw,
      'mq2_baseline': mq2Baseline,
      'mq2_drop': mq2Drop,
      'smoke_level': smokeLevel,
      
      'mq7_raw': mq7Raw,
      'mq7_baseline': mq7Baseline,
      'mq7_drop': mq7Drop,
      'co_level': coLevel,
      
      // System info
      'reading_id': readingId,
    };
    
    // Add combined wildcards if they exist
    if (co2AirQuality != null) {
      map['co2_air_quality'] = co2AirQuality as Map<String, dynamic>;
    }
    
    if (pressureAltitude != null) {
      map['pressure_altitude'] = pressureAltitude as Map<String, dynamic>;
    }
    
    return map;
  }

  // Helper method to determine status of temperature
  String getTemperatureStatus() {
    if (temperature >= 20 && temperature <= 27) {
      return 'Optimal';
    } else if (temperature >= 18 && temperature < 20 || temperature > 27 && temperature <= 30) {
      return 'Acceptable';
    } else {
      return 'Critical';
    }
  }

  // Helper method to determine status of humidity
  String getHumidityStatus() {
    if (humidity >= 45 && humidity <= 70) {
      return 'Optimal';
    } else if (humidity >= 71 && humidity <= 80) {
      return 'Acceptable';
    } else {
      return 'Critical';
    }
  }

  // Helper method to determine status of CO2
  String getCO2Status() {
    if (co2Level >= 300.0 && co2Level <= 800.0) {
      return 'Good';
    } else if (co2Level > 800.0 && co2Level <= 1500.0) {
      return 'Acceptable';
    } else {
      return 'High';
    }
  }

  // Helper method to determine status of light
  // Based on raw light sensor values (inverted: lower = brighter)
  // Raw thresholds:
  // 0-250 = Bright (Full sunlight / strong artificial light)
  // 251-650 = Moderate (Cloudy day / shade in greenhouse)
  // 651-950 = Dim Indoor (Dim lighting, early morning/evening)
  // 951-1250 = Dark Indoor (Minimal light)
  // >1250 = Dark Night (No light, closed room, or night)
  String getLightStatus() {
    if (light <= 250) {
      return 'Bright';
    } else if (light <= 650) {
      return 'Moderate';
    } else if (light <= 950) {
      return 'Dim Indoor';
    } else if (light <= 1250) {
      return 'Dark Indoor';
    } else {
      return 'Dark Night';
    }
  }

  // Helper method to determine status of pressure
  String getPressureStatus() {
    // Simple barometric ranges (hPa)
    // Low: < 990, Normal: 990-1030, High: > 1030
    if (pressure < 990) {
      return 'Low';
    } else if (pressure > 1030) {
      return 'High';
    } else {
      return 'Normal';
    }
  }

  // Helper method to determine status of altitude (in meters)
  String getAltitudeStatus() {
    // General terrain categories (m): Low < 500, Normal 500-1500, High > 1500
    if (altitude < 500) {
      return 'Low';
    } else if (altitude > 1500) {
      return 'High';
    } else {
      return 'Normal';
    }
  }

  // Helper method to determine status of soil moisture
  String getSoilMoistureStatus() {
    // Updated thresholds (from provided spec):
    // critical_low = 15.0
    // low = 30.0
    // optimal_min = 40.0
    // optimal_max = 60.0
    // high = 80.0
    // critical_high = 90.0

    if (soilMoisture < 15.0) {
      return 'Critical (Low)';
    }
    if (soilMoisture >= 15.0 && soilMoisture < 30.0) {
      return 'Low';
    }
    if (soilMoisture >= 30.0 && soilMoisture < 40.0) {
      return 'Acceptable';
    }
    if (soilMoisture >= 40.0 && soilMoisture <= 60.0) {
      return 'Optimal';
    }
    if (soilMoisture > 60.0 && soilMoisture <= 80.0) {
      return 'Acceptable';
    }
    if (soilMoisture > 80.0 && soilMoisture < 90.0) {
      return 'High';
    }
    // soilMoisture >= 90
    return 'Critical (High)';
  }
  
  // Helper method for air quality (MQ135)
  String getAirQualityStatus() {
    return airQuality;
  }
  
  // Helper method for smoke level (MQ2)
  String getSmokeLevelStatus() {
    return smokeLevel;
  }
  
  // Alias for getSmokeLevelStatus to match calls in dashboard_screen.dart
  String getSmokeStatus() {
    return getSmokeLevelStatus();
  }
  
  // Helper method for carbon monoxide level (MQ7)
  String getCOLevelStatus() {
    return coLevel;
  }
  
  // Alias for getCOLevelStatus to match calls in dashboard_screen.dart
  String getCOStatus() {
    return getCOLevelStatus();
  }
  
  // Helper method for flame detection
  String getFlameStatus() {
    return flameDetected ? 'Detected' : 'None';
  }
  
  // Get status color for flame detection
  Color getFlameStatusColor() {
    return flameDetected ? Colors.red : Colors.green;
  }
  
  // Progress value methods for gas sensors
  double getMQ135DropProgressValue() {
    return (mq135Drop / 1000.0).clamp(0.0, 1.0);
  }
  
  double getMQ2DropProgressValue() {
    return (mq2Drop / 1500.0).clamp(0.0, 1.0);
  }
  
  double getMQ7DropProgressValue() {
    return (mq7Drop / 1500.0).clamp(0.0, 1.0);
  }
}