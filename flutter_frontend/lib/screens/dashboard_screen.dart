import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../widgets/sensor_card.dart';
import './ai_recommendation_screen.dart';
import './sensor_analysis_screen.dart';

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
  static const int _defaultPollIntervalSeconds = 2;
  String errorMessage = '';
  Timer? _timer;
  bool _useFeet = false;

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
    _loadSensorData();
    _loadPrefs();
    _timer = Timer.periodic(
      const Duration(seconds: _defaultPollIntervalSeconds),
      (timer) => _pollSensorData(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _useFeet = prefs.getBool('altitude_use_feet') ?? false;
    });
  }

  Future<void> _toggleAltitudeUnits() async {
    final prefs = await SharedPreferences.getInstance();
    final next = !_useFeet;
    await prefs.setBool('altitude_use_feet', next);
    if (!mounted) return;
    setState(() {
      _useFeet = next;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Altitude units: ${_useFeet ? 'feet (ft)' : 'meters (m)'}')),
    );
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
            isApiConnected = false;
            isLoading = false;
            errorMessage = 'Unable to connect to the server';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error loading sensor data: $e';
        });
      }
    }
  }

  Future<void> _pollSensorData() async {
    if (!mounted) return;

    try {
      final data = await ApiService.getSensorData();
      if (mounted) {
        setState(() {
          sensorData = SensorData.fromJson(data);
          lastUpdated = DateTime.now();
          isApiConnected = true;
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

  Future<void> _refreshData() async {
    await _loadSensorData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getSensorStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'normal':
      case 'good':
      case 'safe':
        return Colors.green;
      case 'high':
      case 'low':
      case 'moderate':
      case 'elevated':
        return Colors.orange;
      case 'critical':
      case 'very high':
      case 'very low':
      case 'poor':
      case 'danger':
        return Colors.red;
      case 'detected':
        return Colors.red;
      case 'none':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _calculateProgress(double value, double min, double max) {
    if (max == min) return 0.5;
    final normalized = (value - min) / (max - min);
    return normalized.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 800) {
      crossAxisCount = 3;
    }

    return CustomScrollView(
      slivers: [
        // Header, title, actions
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BannerHero(),
                const SizedBox(height: 16),
                Text(
                  'Greenhouse Dashboard',
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time monitoring of environmental conditions',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Responsive button layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    
                    if (isMobile) {
                      // Mobile layout: Two rows
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First row: AI Recommendations and Export Report
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AIRecommendationScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    minimumSize: const Size(0, 48),
                                  ),
                                  icon: const Icon(Icons.psychology, size: 20),
                                  label: const Text(
                                    'AI Recommendations',
                                    style: TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final path = await ApiService.exportReport();
                                      if (!mounted) return;
                                      final msg = path == 'opened-in-browser'
                                          ? 'Report opened in a new tab'
                                          : 'Report saved to: $path';
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(content: Text('Export failed: $e')),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    minimumSize: const Size(0, 48),
                                  ),
                                  icon: const Icon(Icons.picture_as_pdf, size: 20),
                                  label: const Text(
                                    'Export Report',
                                    style: TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Second row: Export, Refresh, and Connection status (no popup on mobile)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _refreshData,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    minimumSize: const Size(0, 48),
                                  ),
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text(
                                    'Refresh',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Removed duplicate Export Report button on mobile second row
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: isApiConnected
                                        ? Colors.green.withAlpha((0.1 * 255).round())
                                        : Colors.red.withAlpha((0.1 * 255).round()),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isApiConnected ? Icons.cloud_done : Icons.cloud_off,
                                      size: 16,
                                      color: isApiConnected ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isApiConnected ? 'Connected' : 'Offline',
                                      style: TextStyle(
                                        color: isApiConnected ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Desktop layout: Single row
                      return Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AIRecommendationScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.psychology),
                            label: const Text('AI Recommendations'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _refreshData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                final path = await ApiService.exportReport();
                                if (!mounted) return;
                                final msg = path == 'opened-in-browser'
                                    ? 'Report opened in a new tab'
                                    : 'Report saved to: $path';
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(content: Text('Export failed: $e')),
                                );
                              }
                            },
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export Report'),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.tune),
                            tooltip: 'Settings',
                            onSelected: (value) {
                              if (value == 'toggle_alt_units') {
                                _toggleAltitudeUnits();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'toggle_alt_units',
                                child: Row(
                                  children: [
                                    const Icon(Icons.straighten, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Altitude units: ${_useFeet ? 'ft' : 'm'}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isApiConnected
                                  ? Colors.green.withAlpha((0.1 * 255).round())
                                  : Colors.red.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isApiConnected ? Icons.cloud_done : Icons.cloud_off,
                                  size: 16,
                                  color: isApiConnected ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isApiConnected ? 'Connected' : 'Offline',
                                  style: TextStyle(
                                    color: isApiConnected ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        if (isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorMessage.isNotEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (sensorData == null)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No data available')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                // Temperature Card
                SensorCard(
                  icon: Icons.thermostat,
                  iconColor: Colors.orange,
                  title: 'Temperature',
                  value: sensorData!.temperature.toStringAsFixed(1),
                  unit: '°C',
                  status: sensorData!.getTemperatureStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getTemperatureStatus()),
                  progress: _calculateProgress(sensorData!.temperature, 0, 50),
                  progressColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'temperature',
                        ),
                      ),
                    );
                  },
                ),
                
                // Humidity Card
                SensorCard(
                  icon: Icons.water_drop,
                  iconColor: Colors.blue,
                  title: 'Humidity',
                  value: sensorData!.humidity.toStringAsFixed(1),
                  unit: '%',
                  status: sensorData!.getHumidityStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getHumidityStatus()),
                  progress: sensorData!.humidity / 100,
                  progressColor: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'humidity',
                        ),
                      ),
                    );
                  },
                ),
                
                // Soil Moisture Card
                SensorCard(
                  icon: Icons.grass,
                  iconColor: Colors.brown,
                  title: 'Soil Moisture',
                  value: sensorData!.soilMoisture.toStringAsFixed(1),
                  unit: '%',
                  status: sensorData!.getSoilMoistureStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getSoilMoistureStatus()),
                  progress: sensorData!.soilMoisture / 100,
                  progressColor: Colors.brown,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'soil_moisture',
                        ),
                      ),
                    );
                  },
                ),
                
                // Light Level Card
                SensorCard(
                  icon: Icons.wb_sunny,
                  iconColor: Colors.amber,
                  title: 'Light Level',
                  value: sensorData!.light.toStringAsFixed(0),
                  unit: 'lux',
                  status: sensorData!.getLightStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getLightStatus()),
                  progress: _calculateProgress(sensorData!.light, 0, 4095),
                  progressColor: Colors.amber,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'light_level',
                        ),
                      ),
                    );
                  },
                ),
                
                // Flame Detection Card
                SensorCard(
                  icon: Icons.local_fire_department,
                  iconColor: Colors.red,
                  title: 'Flame Detection',
                  value: sensorData!.flameDetected ? 'Detected' : 'None',
                  unit: '',
                  status: sensorData!.getFlameStatus(),
                  statusColor: sensorData!.getFlameStatusColor(),
                  progress: sensorData!.flameDetected ? 1.0 : 0.0,
                  progressColor: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'flame',
                        ),
                      ),
                    );
                  },
                ),

                // Air Quality (MQ135 + CO₂)
                SensorCard(
                  icon: Icons.air,
                  iconColor: Colors.teal,
                  title: 'CO₂',
                  value: sensorData!.co2Level.toStringAsFixed(0),
                  unit: 'ppm',
                  status: 'Air Quality: ${sensorData!.getAirQualityStatus()}',
                  statusColor: _getSensorStatusColor(sensorData!.getAirQualityStatus()),
                  progress: _calculateProgress(sensorData!.co2Level, 300, 1500),
                  progressColor: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'air_quality',
                        ),
                      ),
                    );
                  },
                ),

                // Flammable Gas (MQ2)
                SensorCard(
                  icon: Icons.smoke_free,
                  iconColor: Colors.deepOrange,
                  title: 'Flammable Gas',
                  value: sensorData!.mq2Drop.toStringAsFixed(0),
                  unit: 'ppm',
                  status: sensorData!.getSmokeStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getSmokeStatus()),
                  progress: sensorData!.getMQ2DropProgressValue(),
                  progressColor: Colors.deepOrange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'smoke',
                        ),
                      ),
                    );
                  },
                ),

                // Carbon Monoxide (MQ7)
                SensorCard(
                  icon: Icons.warning,
                  iconColor: Colors.deepPurple,
                  title: 'Carbon Monoxide',
                  value: sensorData!.mq7Drop.toStringAsFixed(0),
                  unit: 'ppm',
                  status: sensorData!.getCOStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getCOStatus()),
                  progress: sensorData!.getMQ7DropProgressValue(),
                  progressColor: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'co',
                        ),
                      ),
                    );
                  },
                ),

                // Pressure
                SensorCard(
                  icon: Icons.compress,
                  iconColor: Colors.indigo,
                  title: 'Pressure',
                  value: sensorData!.pressure.toStringAsFixed(1),
                  unit: 'hPa',
                  status: sensorData!.getPressureStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getPressureStatus()),
                  progress: _calculateProgress(sensorData!.pressure, 950, 1050),
                  progressColor: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'pressure',
                        ),
                      ),
                    );
                  },
                ),

                // Altitude
                SensorCard(
                  icon: Icons.landscape,
                  iconColor: Colors.green,
                  title: 'Altitude',
                  value: (_useFeet
                          ? (sensorData!.altitude * 3.28084)
                          : sensorData!.altitude)
                      .toStringAsFixed(1),
                  unit: _useFeet ? 'ft' : 'm',
                  status: sensorData!.getAltitudeStatus(),
                  statusColor: _getSensorStatusColor(sensorData!.getAltitudeStatus()),
                  // Progress is illustrative; normalize within 0-3000m range
                  progress: _calculateProgress(sensorData!.altitude, 0, 3000),
                  progressColor: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SensorAnalysisScreen(
                          sensorType: 'altitude',
                        ),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
      ],
    );
  }

}

// Simple reusable banner widget with asset fallback
class _BannerHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Responsive height
    final width = MediaQuery.of(context).size.width;
    double height = 160;
    if (width >= 1200) {
      height = 260;
    } else if (width >= 800) {
      height = 200;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Try to load the asset image; fallback to gradient if missing
            Image.asset(
              'assets/greenhouse_banner.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF0D1F12), const Color(0xFF1B3A1F)]
                          : [const Color(0xFFF3EEE6), const Color(0xFFE6D9C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
            // Overlay to improve legibility
            Container(
              color: isDark
                  ? Colors.black.withAlpha((0.30 * 255).round())
                  : scheme.surface.withAlpha((0.22 * 255).round()),
            ),
            // Decorative content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon with shadow for visibility
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.15 * 255).round()),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: width >= 1200 ? 110 : (width >= 800 ? 90 : 80),
                        height: width >= 1200 ? 110 : (width >= 800 ? 90 : 80),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) {
                          // Fallback to eco icon if app_icon.png is missing
                          return Container(
                            width: width >= 1200 ? 110 : (width >= 800 ? 90 : 80),
                            height: width >= 1200 ? 110 : (width >= 800 ? 90 : 80),
                            decoration: BoxDecoration(
                              color: scheme.primary.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.eco,
                              color: scheme.primary,
                              size: width >= 1200 ? 60 : (width >= 800 ? 48 : 40),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EcoView Greenhouse',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: width >= 1200 ? 38 : (width >= 800 ? 32 : 26),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Live insights • Smart alerts • AI recommendations',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface.withAlpha((0.9 * 255).round()),
                              fontSize: width >= 1200 ? 18 : (width >= 800 ? 16 : 14),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
