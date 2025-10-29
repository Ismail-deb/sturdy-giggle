import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../widgets/sensor_card.dart';
import './ai_recommendation_screen.dart';
import './sensor_detail_helper.dart';
import './settings_screen.dart';
import './sensor_info_screen.dart';

// Conditional import for web
import 'package:universal_html/html.dart' as html;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isApiConnected = false;
  DateTime lastUpdated = DateTime.now();
  SensorData? sensorData;
  bool isLoading = true;
  // Polling interval in seconds (configurable later via Settings)
  static const int _defaultPollIntervalSeconds = 2;
  String errorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
    _loadSensorData();
    
    // Start a periodic poll for new sensor data.
    // We avoid calling checkHealth on every tick to reduce network load and UI churn.
    _timer = Timer.periodic(const Duration(seconds: _defaultPollIntervalSeconds), (timer) {
      _pollSensorData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkApiConnection() async {
    try {
      final isConnected = await ApiService.checkHealth();
      if (mounted) {
        setState(() {
          isApiConnected = isConnected;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isApiConnected = false;
        });
      }
    }
  }

  Future<void> _loadSensorData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });
    }

    try {
      if (await ApiService.checkHealth()) {
        final data = await ApiService.getSensorData();
        if (mounted) {
          setState(() {
            sensorData = SensorData.fromJson(data);
            isApiConnected = true;
            isLoading = false;
            lastUpdated = DateTime.now();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'API is not available. Check your Flask server.';
            isApiConnected = false;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  /// Periodic poll that runs frequently. Keeps UI responsive by avoiding
  /// heavy state updates unless the underlying data actually changed.
  Future<void> _pollSensorData() async {
    try {
      final data = await ApiService.getSensorData();
      final newData = SensorData.fromJson(data);

      // If there's no existing data, or the timestamp changed, update UI.
    final shouldUpdate = sensorData == null || sensorData!.timestamp != newData.timestamp;

      if (shouldUpdate && mounted) {
        setState(() {
          sensorData = newData;
          isApiConnected = true;
          lastUpdated = DateTime.now();
          // Do not toggle isLoading here to avoid UI jitter on frequent updates.
        });
      }
    } catch (e) {
      // Do not spam the UI with errors on every tick; update the connection flag.
      if (mounted) {
        setState(() {
          isApiConnected = false;
        });
      }
    }
  }

  void _refreshData() {
    _loadSensorData();
  }

  Future<void> _showAIRecommendations(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          width: isSmallScreen ? size.width * 0.9 : size.width * 0.8,
          height: size.height * 0.8,
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
          child: const AIRecommendationScreen(),
        ),
      ),
    );
  }
  
  Future<void> _showAlertsDialog(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;
    
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<dynamic>>(
        future: ApiService.getAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
            );
          }

          if (snapshot.hasError) {
            return _buildMockAlertsDialog(context, size, isSmallScreen);
          }

          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return _buildMockAlertsDialog(context, size, isSmallScreen);
          }

          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.notifications_active, color: Colors.red),
                SizedBox(width: 8),
                Text('Greenhouse Alerts'),
              ],
            ),
            content: SizedBox(
              width: isSmallScreen ? size.width * 0.8 : size.width * 0.5,
              height: size.height * 0.5,
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final IconData icon = _getAlertIcon(alert['type'] ?? 'general');
                  final Color color = _getAlertColor(alert['severity'] ?? 'info');
                  final DateTime time = DateTime.fromMillisecondsSinceEpoch(
                      ((alert['timestamp'] ?? DateTime.now().millisecondsSinceEpoch / 1000) * 1000).round());

                  return _buildAlertItem(
                    alert['title'] ?? 'Alert',
                    alert['message'] ?? 'No details available',
                    icon,
                    color,
                    time,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildMockAlertsDialog(BuildContext context, Size size, bool isSmallScreen) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).cardColor,
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.red),
          SizedBox(width: 8),
          Text('Greenhouse Alerts'),
        ],
      ),
      content: SizedBox(
        width: isSmallScreen ? size.width * 0.8 : size.width * 0.5,
        height: size.height * 0.4,
        child: ListView(
          children: [
            _buildAlertItem(
              'High Temperature Warning', 
              'Temperature has exceeded 26°C. Consider ventilation.',
              Icons.thermostat,
              Colors.orange,
              DateTime.now().subtract(const Duration(minutes: 15)),
            ),
            _buildAlertItem(
              'CO2 Level Alert', 
              'CO2 level is rising steadily over the past hour.',
              Icons.co2,
              Colors.amber,
              DateTime.now().subtract(const Duration(minutes: 45)),
            ),
            _buildAlertItem(
              'Soil Moisture Low', 
              'Zone 2 soil moisture below 30%. Consider watering.',
              Icons.grass,
              Colors.red,
              DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
  
  Widget _buildAlertItem(String title, String message, IconData icon, Color color, DateTime time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha((0.2 * 255).round()),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${_getTimeAgo(time)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Show a dialog with full alert details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  Text(
                    'Time: ${time.hour}:${time.minute.toString().padLeft(2, '0')} - ${_getTimeAgo(time)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
  
  IconData _getAlertIcon(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'co2':
      case 'co2_level':
        return Icons.co2;
      case 'light':
        return Icons.light_mode;
      case 'pressure':
        return Icons.compress;
      case 'soil_moisture':
        return Icons.grass;
      case 'air_quality':
        return Icons.air;
      case 'flammable_gas':
      case 'gas':
        return Icons.local_fire_department;
      case 'carbon_monoxide':
      case 'co':
        return Icons.warning_amber;
      case 'flame':
      case 'flame_detection':
        return Icons.local_fire_department;
      default:
        return Icons.warning_amber;
    }
  }
  
  Color _getAlertColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.amber;
    }
  }
  
  Future<void> _openSettings(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    
    if (result == true) {
      // If settings were updated successfully, refresh data
      _loadSensorData();
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
        return Colors.green;
      case 'acceptable':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      // Light sensor statuses
      case 'bright':
      case 'moderate':
        return Colors.green;
      case 'dim indoor':
        return Colors.orange;
      case 'low light':
      case 'dark night':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  Color _getProgressColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
        return Colors.green;
      case 'acceptable':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      // Light sensor statuses
      case 'bright':
      case 'moderate':
        return Colors.green;
      case 'dim indoor':
        return Colors.orange;
      case 'low light':
      case 'dark night':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> _exportDataToCSV() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating comprehensive report with AI analysis...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Fetch comprehensive report from backend
      final response = await http.get(
        Uri.parse('${await ApiService.getBaseUrl()}/api/export-report')
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch report data');
      }

      final reportData = json.decode(response.body);

      // Build comprehensive CSV with AI analysis
      final csvBuffer = StringBuffer();
      
      // Title and metadata
      csvBuffer.writeln('═══════════════════════════════════════════════════════════════');
      csvBuffer.writeln('ECOVIEW GREENHOUSE MONITORING SYSTEM - COMPREHENSIVE REPORT');
      csvBuffer.writeln('═══════════════════════════════════════════════════════════════');
      csvBuffer.writeln('');
      csvBuffer.writeln('Report Generated:,${reportData['report_generated']}');
      csvBuffer.writeln('System:,${reportData['greenhouse_name']}');
      csvBuffer.writeln('');
      
      // Overview Section
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('GREENHOUSE OVERVIEW');
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      final overview = reportData['overview'];
      csvBuffer.writeln('Status:,${overview['status']}');
      csvBuffer.writeln('Health Score:,${reportData['health_score']}/100');
      csvBuffer.writeln('Active Sensors:,${overview['active_sensors']}/${overview['total_sensors']}');
      csvBuffer.writeln('');
      csvBuffer.writeln('Summary:');
      csvBuffer.writeln('"${overview['summary']}"');
      csvBuffer.writeln('');
      
      // Current Conditions
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('CURRENT CONDITIONS');
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      final conditions = reportData['current_conditions'];
      
      csvBuffer.writeln('Temperature:');
      csvBuffer.writeln('  - BMP280 Sensor:,${conditions['temperature']['bmp280']}');
      csvBuffer.writeln('  - DHT22 Sensor:,${conditions['temperature']['dht22']}');
      csvBuffer.writeln('  - Average:,${conditions['temperature']['average']}');
      csvBuffer.writeln('');
      
      csvBuffer.writeln('Humidity:,${conditions['humidity']}');
      csvBuffer.writeln('');
      
      csvBuffer.writeln('Air Quality:');
      csvBuffer.writeln('  - CO2 (MQ135):,${conditions['air_quality']['mq135_co2']}');
      csvBuffer.writeln('  - Flammable Gas (MQ2):,${conditions['air_quality']['mq2_gas']}');
      csvBuffer.writeln('  - Carbon Monoxide (MQ7):,${conditions['air_quality']['mq7_co']}');
      csvBuffer.writeln('');
      
      csvBuffer.writeln('Atmospheric Conditions:');
      csvBuffer.writeln('  - Pressure:,${conditions['atmospheric']['pressure']}');
      csvBuffer.writeln('  - Altitude:,${conditions['atmospheric']['altitude']}');
      csvBuffer.writeln('');
      
      csvBuffer.writeln('Light Intensity:,${conditions['light_intensity']}');
      csvBuffer.writeln('Fire Detection:,${conditions['flame_detection']}');
      csvBuffer.writeln('');
      
      // Alerts Summary
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('ALERTS & WARNINGS');
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      final alertSummary = reportData['alert_summary'];
      csvBuffer.writeln('Total Alerts:,${alertSummary['total_alerts']}');
      csvBuffer.writeln('Critical:,${alertSummary['critical_count']}');
      csvBuffer.writeln('Warnings:,${alertSummary['warning_count']}');
      csvBuffer.writeln('');
      
      if (alertSummary['alerts'] != null && alertSummary['alerts'].isNotEmpty) {
        csvBuffer.writeln('Active Alerts:');
        for (var alert in alertSummary['alerts']) {
          csvBuffer.writeln('  [${alert['level']}] ${alert['type']}:,"${alert['message']}"');
        }
      } else {
        csvBuffer.writeln('No active alerts - All systems optimal');
      }
      csvBuffer.writeln('');
      
      // AI Recommendations
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('AI-POWERED RECOMMENDATIONS');
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      final recommendations = reportData['ai_recommendations'] as List?;
      if (recommendations != null && recommendations.isNotEmpty) {
        for (int i = 0; i < recommendations.length; i++) {
          final rec = recommendations[i];
          csvBuffer.writeln('${i + 1}. ${rec['category']} - ${rec['priority']}');
          csvBuffer.writeln('   "${rec['recommendation']}"');
          csvBuffer.writeln('');
        }
      } else {
        csvBuffer.writeln('All conditions are optimal. Continue current maintenance routine.');
      }
      csvBuffer.writeln('');
      
      // Sensor Analysis
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('DETAILED SENSOR ANALYSIS');
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      final analysis = reportData['sensor_analysis'];
      
      if (analysis['temperature'] != null) {
        csvBuffer.writeln('Temperature Analysis:');
        csvBuffer.writeln('  Status:,${analysis['temperature']['status']}');
        csvBuffer.writeln('  Value:,${analysis['temperature']['value']}°C');
        csvBuffer.writeln('  Message:,"${analysis['temperature']['message']}"');
        csvBuffer.writeln('');
      }
      
      if (analysis['humidity'] != null) {
        csvBuffer.writeln('Humidity Analysis:');
        csvBuffer.writeln('  Status:,${analysis['humidity']['status']}');
        csvBuffer.writeln('  Value:,${analysis['humidity']['value']}%');
        csvBuffer.writeln('  Message:,"${analysis['humidity']['message']}"');
        csvBuffer.writeln('');
      }
      
      if (analysis['air_quality'] != null) {
        csvBuffer.writeln('Air Quality Analysis:');
        csvBuffer.writeln('  Status:,${analysis['air_quality']['status']}');
        csvBuffer.writeln('  CO2 Level:,${analysis['air_quality']['mq135']} PPM');
        csvBuffer.writeln('  Message:,"${analysis['air_quality']['message']}"');
        csvBuffer.writeln('');
      }
      
      if (analysis['light'] != null) {
        csvBuffer.writeln('Light Analysis:');
        csvBuffer.writeln('  Status:,${analysis['light']['status']}');
        csvBuffer.writeln('  Intensity:,${analysis['light']['value']} lux');
        csvBuffer.writeln('  Message:,"${analysis['light']['message']}"');
        csvBuffer.writeln('');
      }
      
      // Historical Data
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('HISTORICAL DATA (Last 20 Readings)');
      csvBuffer.writeln('─────────────────────────────────────────────────────────────────');
      csvBuffer.writeln('');
      
      // Historical data headers
      csvBuffer.writeln(
        'Timestamp,Temp(BMP),Temp(DHT),Humidity%,CO2(PPM),Gas(PPM),CO(PPM),'
        'Pressure(hPa),Altitude(m),Flame,Light(lux)'
      );

      // Historical data rows
      final history = reportData['historical_data'] as List?;
      if (history != null) {
        for (var reading in history) {
          final timestamp = reading['timestamp'] ?? '';
          final tempBMP = reading['temperature_bmp280'] ?? '';
          final tempDHT = reading['temperature_dht22'] ?? '';
          final humidity = reading['humidity'] ?? '';
          final mq135 = reading['mq135_drop'] ?? '';
          final mq2 = reading['mq2_drop'] ?? '';
          final mq7 = reading['mq7_drop'] ?? '';
          final pressure = reading['pressure'] ?? '';
          final altitude = reading['altitude'] ?? '';
          final flame = reading['flame_detected'] ?? '';
          final light = reading['light_intensity'] ?? '';

          csvBuffer.writeln(
            '$timestamp,$tempBMP,$tempDHT,$humidity,$mq135,$mq2,$mq7,'
            '$pressure,$altitude,$flame,$light'
          );
        }
      }
      
      csvBuffer.writeln('');
      csvBuffer.writeln('═══════════════════════════════════════════════════════════════');
      csvBuffer.writeln('END OF REPORT');
      csvBuffer.writeln('═══════════════════════════════════════════════════════════════');

      final csvString = csvBuffer.toString();

      // Create filename with timestamp
      final now = DateTime.now();
      final filename = 'EcoView_Report_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(now)}.csv';

      if (kIsWeb) {
        // Web platform: Use universal_html
        final blob = html.Blob([csvString], 'text/csv;charset=utf-8');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comprehensive report downloaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Mobile/Desktop platforms: Save to Downloads folder
        try {
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final file = File('${directory.path}/$filename');
            await file.writeAsString(csvString);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Comprehensive report saved to Downloads:\n$filename'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
            return;
          }
        } catch (e) {
          // If Downloads directory not available, try app documents directory
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$filename');
          await file.writeAsString(csvString);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report saved to:\n${directory.path}/$filename'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully! ($filename)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on a small screen (like a mobile device)
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      // Add a drawer for small screens
      drawer: isSmallScreen ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF121212),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 30,
                    child: Icon(Icons.eco, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Greenhouse',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'Monitoring System',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sensors_outlined),
              title: const Text('Sensors'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const SensorInfoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Alerts'),
              onTap: () {
                Navigator.pop(context);
                _showAlertsDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data (CSV)'),
              onTap: () {
                Navigator.pop(context);
                _exportDataToCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sensor Information'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const SensorInfoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Server Settings'),
              onTap: () {
                Navigator.pop(context);
                _openSettings(context);
              },
            ),
          ],
        ),
      ) : null,
      
      // Add app bar on small screens only
      appBar: isSmallScreen ? AppBar(
        title: const Text('EcoView'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportDataToCSV,
            tooltip: 'Export Data (CSV)',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
            tooltip: 'Server Settings',
          ),
        ],
      ) : null,
      
      body: Row(
        children: [
          // Sidebar navigation - only show on larger screens
          if (!isSmallScreen)
            NavigationRail(
              backgroundColor: const Color(0xFF121212),
              selectedIndex: 0,
              onDestinationSelected: (index) {
                // Handle navigation
                if (index == 1) {
                  // Sensors button
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const SensorInfoScreen()),
                  );
                } else if (index == 2) {
                  _showAlertsDialog(context);
                }
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.sensors_outlined),
                  selectedIcon: Icon(Icons.sensors),
                  label: Text('Sensors'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_active_outlined),
                  selectedIcon: Icon(Icons.notifications_active),
                  label: Text('Alerts'),
                ),
              ],
            ),
          
          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Don't show header on small screens (appbar replaces it)
                  if (!isSmallScreen)
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 20,
                          child: Icon(Icons.eco, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Greenhouse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Monitoring System',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Collapsible sidebar toggle
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () {
                            // Handle sidebar toggle
                          },
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Dashboard title and description
                  const Text(
                    'Greenhouse Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Real-time monitoring of environmental conditions',
                    style: TextStyle(color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Actions section with AI recommendations and refresh button
                  // Use a responsive layout that wraps on smaller screens
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Check if we have enough width for a single row
                      final isSmallScreen = constraints.maxWidth < 600;
                      
                      if (isSmallScreen) {
                        // Stack vertically on small screens
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // AI Recommendations button
                            ElevatedButton.icon(
                              onPressed: () => _showAIRecommendations(context),
                              icon: const Icon(Icons.lightbulb_outline),
                              label: const Text('AI Recommendations'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Last updated time
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  'Last updated: ${lastUpdated.hour}:${lastUpdated.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Refresh button
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _refreshData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        );
                      } else {
                        // Use horizontal layout on larger screens
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // AI Recommendations button
                            ElevatedButton.icon(
                              onPressed: () => _showAIRecommendations(context),
                              icon: const Icon(Icons.lightbulb_outline),
                              label: const Text('AI Recommendations'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            
                            // Group updated time and refresh
                            Row(
                              children: [
                                // Last updated time
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Last updated: ${lastUpdated.hour}:${lastUpdated.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Refresh button
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _refreshData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // Settings button
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => _openSettings(context),
                                  icon: const Icon(Icons.settings),
                                  label: const Text('Settings'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // API Connection status
                  Row(
                    children: [
                      Icon(
                        isApiConnected ? Icons.check_circle : Icons.error,
                        color: isApiConnected ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isApiConnected ? 'Connected to API' : 'API Disconnected',
                        style: TextStyle(
                          color: isApiConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main content - varies based on state
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading sensor data...'),
          ],
        ),
      );
    }
    
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (sensorData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }
    
    // Build sensor cards grid with fixed card size to prevent any overflow issues
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0, // Smaller cards
        childAspectRatio: 1.2,  // More compact aspect ratio
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 9, // 9 sensor cards (removed alerts card)
      itemBuilder: (context, index) {
        // Create cards based on index
        switch (index) {
          case 0:
            return SensorCard(
              title: 'Temperature',
              value: '${sensorData!.temperature}',
              unit: '°C',
              icon: Icons.thermostat,
              iconColor: Colors.orange,
              status: sensorData!.getTemperatureStatus(),
              statusColor: _getStatusColor(sensorData!.getTemperatureStatus()),
              progress: 0.7,
              progressColor: _getProgressColor(sensorData!.getTemperatureStatus()),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Temperature', sensorData!),
            );
          case 1:
            return SensorCard(
              title: 'Humidity',
              value: '${sensorData!.humidity}',
              unit: '%',
              icon: Icons.water_drop,
              iconColor: Colors.blue,
              status: sensorData!.getHumidityStatus(),
              statusColor: _getStatusColor(sensorData!.getHumidityStatus()),
              progress: 0.6,
              progressColor: _getProgressColor(sensorData!.getHumidityStatus()),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Humidity', sensorData!),
            );
          case 2:
            // CO2 & Air Quality combined card - Show MQ135 drop value
            final mq135Drop = sensorData!.mq135Drop;
            final airQuality = sensorData!.airQuality;
            return SensorCard(
              title: 'CO₂ & Air Quality',
              value: mq135Drop.toStringAsFixed(0),
              unit: 'ppm',
              icon: Icons.co2,
              iconColor: Colors.green,
              status: airQuality,
              statusColor: _getStatusColor(airQuality),
              progress: sensorData!.getMQ135DropProgressValue(),
              progressColor: _getProgressColor(airQuality),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'CO₂ & Air Quality', sensorData!),
            );
          case 3:
            return SensorCard(
              title: 'Light',
              value: '${sensorData!.light.toInt()}',
              unit: 'lux',
              icon: Icons.light_mode,
              iconColor: Colors.amber,
              status: sensorData!.getLightStatus(),
              statusColor: _getStatusColor(sensorData!.getLightStatus()),
              progress: 0.8,
              progressColor: _getProgressColor(sensorData!.getLightStatus()),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Light', sensorData!),
            );
          case 4:
            // Pressure & Altitude combined card
            final pressureValue = sensorData!.pressureAltitude?['pressure'] ?? sensorData!.pressure;
            final altitudeValue = sensorData!.pressureAltitude?['altitude'] ?? sensorData!.altitude;
            return SensorCard(
              title: 'Pressure & Alt.',
              value: '$pressureValue',
              unit: 'hPa',
              icon: Icons.height,
              iconColor: Colors.purple,
              status: '${altitudeValue.round()}m',
              statusColor: _getStatusColor(sensorData!.getPressureStatus()),
              progress: 0.65,
              progressColor: _getProgressColor(sensorData!.getPressureStatus()),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Pressure & Altitude', sensorData!),
            );
          case 5:
            return SensorCard(
              title: 'Soil Moisture',
              value: '${sensorData!.soilMoisture}',
              unit: '%',
              icon: Icons.grass,
              iconColor: Colors.brown,
              status: sensorData!.getSoilMoistureStatus(),
              statusColor: _getStatusColor(sensorData!.getSoilMoistureStatus()),
              progress: 0.45,
              progressColor: _getProgressColor(sensorData!.getSoilMoistureStatus()),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Soil Moisture', sensorData!),
            );
          case 6:
            // Flammable Gas (MQ2) Card - Show drop value
            final mq2Drop = sensorData!.mq2Drop;
            final smokeStatus = sensorData!.getSmokeStatus();
            return SensorCard(
              title: 'Flammable Gas',
              value: mq2Drop.toStringAsFixed(0),
              unit: 'ppm',
              icon: Icons.local_fire_department,
              iconColor: Colors.amber,
              status: smokeStatus,
              statusColor: _getStatusColor(smokeStatus),
              progress: sensorData!.getMQ2DropProgressValue(),
              progressColor: _getProgressColor(smokeStatus),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Flammable Gas', sensorData!),
            );
          case 7:
            // Carbon Monoxide (MQ7) Card - Show drop value and status
            final mq7Drop = sensorData!.mq7Drop;
            final coStatus = sensorData!.getCOStatus();
            return SensorCard(
              title: 'Carbon Monoxide',
              value: mq7Drop.toStringAsFixed(0),
              unit: 'ppm',
              icon: Icons.warning_amber,
              iconColor: Colors.deepOrange,
              status: coStatus, // Status: Safe/Elevated/High based on baselines
              statusColor: _getStatusColor(coStatus),
              progress: sensorData!.getMQ7DropProgressValue(),
              progressColor: _getProgressColor(coStatus),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Carbon Monoxide', sensorData!),
            );
          case 8:
            // Flame Detection Card
            return SensorCard(
              title: 'Flame Detection',
              value: sensorData!.flameDetected ? 'Detected' : 'None',
              unit: '',
              icon: Icons.local_fire_department,
              iconColor: sensorData!.getFlameStatusColor(),
              status: sensorData!.getFlameStatus(),
              statusColor: sensorData!.getFlameStatusColor(),
              progress: sensorData!.flameDetected ? 1.0 : 0.0,
              progressColor: sensorData!.getFlameStatusColor(),
              onTap: () => SensorDetailHelper.showSensorDetails(context, 'Flame Detection', sensorData!),
            );
          // No case 9 - removed the alerts card from the grid since it's now in the navigation
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}