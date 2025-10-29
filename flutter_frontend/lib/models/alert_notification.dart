class AlertNotification {
  final String id;
  final String title;
  final String message;
  final String sensorType;
  final String severity;
  final double value;
  final String unit;
  final DateTime timestamp;
  final bool isRead;
  
  AlertNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.sensorType,
    required this.severity,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.isRead = false,
  });
  
  factory AlertNotification.fromJson(Map<String, dynamic> json) {
    return AlertNotification(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Alert',
      message: json['message'] ?? '',
      sensorType: json['sensor_type'] ?? '',
      severity: json['severity'] ?? 'medium',
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['timestamp'] * 1000).toInt())
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'sensor_type': sensorType,
      'severity': severity,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.millisecondsSinceEpoch / 1000,
      'is_read': isRead,
    };
  }
  
  AlertNotification copyWith({bool? isRead}) {
    return AlertNotification(
      id: id,
      title: title,
      message: message,
      sensorType: sensorType,
      severity: severity,
      value: value,
      unit: unit,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}