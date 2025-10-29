import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ThresholdSettingsScreen extends StatefulWidget {
  const ThresholdSettingsScreen({super.key});

  @override
  State<ThresholdSettingsScreen> createState() => _ThresholdSettingsScreenState();
}

class _ThresholdSettingsScreenState extends State<ThresholdSettingsScreen> {
  // Temperature thresholds
  final TextEditingController _tempOptimalMinController = TextEditingController();
  final TextEditingController _tempOptimalMaxController = TextEditingController();
  final TextEditingController _tempAcceptableMinController = TextEditingController();
  final TextEditingController _tempAcceptableMaxController = TextEditingController();

  // Humidity thresholds
  final TextEditingController _humidityOptimalMinController = TextEditingController();
  final TextEditingController _humidityOptimalMaxController = TextEditingController();
  final TextEditingController _humidityAcceptableMinController = TextEditingController();
  final TextEditingController _humidityAcceptableMaxController = TextEditingController();

  // Gas sensor thresholds (MQ135 - Air Quality)
  final TextEditingController _mq135GoodController = TextEditingController();
  final TextEditingController _mq135PoorController = TextEditingController();

  // Gas sensor thresholds (MQ2 - Flammable Gas)
  final TextEditingController _mq2SafeController = TextEditingController();
  final TextEditingController _mq2HighController = TextEditingController();

  // Gas sensor thresholds (MQ7 - Carbon Monoxide)
  final TextEditingController _mq7SafeController = TextEditingController();
  final TextEditingController _mq7HighController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThresholds();
  }

  @override
  void dispose() {
    _tempOptimalMinController.dispose();
    _tempOptimalMaxController.dispose();
    _tempAcceptableMinController.dispose();
    _tempAcceptableMaxController.dispose();
    _humidityOptimalMinController.dispose();
    _humidityOptimalMaxController.dispose();
    _humidityAcceptableMinController.dispose();
    _humidityAcceptableMaxController.dispose();
    _mq135GoodController.dispose();
    _mq135PoorController.dispose();
    _mq2SafeController.dispose();
    _mq2HighController.dispose();
    _mq7SafeController.dispose();
    _mq7HighController.dispose();
    super.dispose();
  }

  Future<void> _loadThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    final thresholdsJson = prefs.getString('sensor_thresholds');

    Map<String, dynamic> thresholds;
    if (thresholdsJson != null) {
      thresholds = jsonDecode(thresholdsJson);
    } else {
      // Default thresholds from THRESHOLDS.md
      thresholds = _getDefaultThresholds();
    }

    setState(() {
      // Temperature
      _tempOptimalMinController.text = thresholds['temperature']['optimal']['min'].toString();
      _tempOptimalMaxController.text = thresholds['temperature']['optimal']['max'].toString();
      _tempAcceptableMinController.text = thresholds['temperature']['acceptable']['min'].toString();
      _tempAcceptableMaxController.text = thresholds['temperature']['acceptable']['max'].toString();

      // Humidity
      _humidityOptimalMinController.text = thresholds['humidity']['optimal']['min'].toString();
      _humidityOptimalMaxController.text = thresholds['humidity']['optimal']['max'].toString();
      _humidityAcceptableMinController.text = thresholds['humidity']['acceptable']['min'].toString();
      _humidityAcceptableMaxController.text = thresholds['humidity']['acceptable']['max'].toString();

      // MQ135
      _mq135GoodController.text = thresholds['mq135']['good'].toString();
      _mq135PoorController.text = thresholds['mq135']['poor'].toString();

      // MQ2
      _mq2SafeController.text = thresholds['mq2']['safe'].toString();
      _mq2HighController.text = thresholds['mq2']['high'].toString();

      // MQ7
      _mq7SafeController.text = thresholds['mq7']['safe'].toString();
      _mq7HighController.text = thresholds['mq7']['high'].toString();

      _isLoading = false;
    });
  }

  Map<String, dynamic> _getDefaultThresholds() {
    return {
      'temperature': {
        'optimal': {'min': 21, 'max': 27},
        'acceptable': {'min': 18, 'max': 30},
      },
      'humidity': {
        'optimal': {'min': 60, 'max': 75},
        'acceptable': {'min': 50, 'max': 85},
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

  Future<void> _saveThresholds() async {
    try {
      final thresholds = {
        'temperature': {
          'optimal': {
            'min': int.parse(_tempOptimalMinController.text),
            'max': int.parse(_tempOptimalMaxController.text),
          },
          'acceptable': {
            'min': int.parse(_tempAcceptableMinController.text),
            'max': int.parse(_tempAcceptableMaxController.text),
          },
        },
        'humidity': {
          'optimal': {
            'min': int.parse(_humidityOptimalMinController.text),
            'max': int.parse(_humidityOptimalMaxController.text),
          },
          'acceptable': {
            'min': int.parse(_humidityAcceptableMinController.text),
            'max': int.parse(_humidityAcceptableMaxController.text),
          },
        },
        'mq135': {
          'good': int.parse(_mq135GoodController.text),
          'poor': int.parse(_mq135PoorController.text),
        },
        'mq2': {
          'safe': int.parse(_mq2SafeController.text),
          'high': int.parse(_mq2HighController.text),
        },
        'mq7': {
          'safe': int.parse(_mq7SafeController.text),
          'high': int.parse(_mq7HighController.text),
        },
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sensor_thresholds', jsonEncode(thresholds));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thresholds saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate thresholds were updated
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving thresholds: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text('Are you sure you want to reset all thresholds to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final defaults = _getDefaultThresholds();
      setState(() {
        _tempOptimalMinController.text = defaults['temperature']['optimal']['min'].toString();
        _tempOptimalMaxController.text = defaults['temperature']['optimal']['max'].toString();
        _tempAcceptableMinController.text = defaults['temperature']['acceptable']['min'].toString();
        _tempAcceptableMaxController.text = defaults['temperature']['acceptable']['max'].toString();
        _humidityOptimalMinController.text = defaults['humidity']['optimal']['min'].toString();
        _humidityOptimalMaxController.text = defaults['humidity']['optimal']['max'].toString();
        _humidityAcceptableMinController.text = defaults['humidity']['acceptable']['min'].toString();
        _humidityAcceptableMaxController.text = defaults['humidity']['acceptable']['max'].toString();
        _mq135GoodController.text = defaults['mq135']['good'].toString();
        _mq135PoorController.text = defaults['mq135']['poor'].toString();
        _mq2SafeController.text = defaults['mq2']['safe'].toString();
        _mq2HighController.text = defaults['mq2']['high'].toString();
        _mq7SafeController.text = defaults['mq7']['safe'].toString();
        _mq7HighController.text = defaults['mq7']['high'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Threshold Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Thresholds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Configure sensor thresholds for alerts and status indicators. Changes apply immediately.',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildThresholdSection(
            title: 'Temperature (°C)',
            icon: Icons.thermostat,
            color: Colors.red,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tempOptimalMinController,
                      label: 'Optimal Min',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _tempOptimalMaxController,
                      label: 'Optimal Max',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tempAcceptableMinController,
                      label: 'Acceptable Min',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _tempAcceptableMaxController,
                      label: 'Acceptable Max',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildThresholdSection(
            title: 'Humidity (%)',
            icon: Icons.water_drop,
            color: Colors.blue,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _humidityOptimalMinController,
                      label: 'Optimal Min',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _humidityOptimalMaxController,
                      label: 'Optimal Max',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _humidityAcceptableMinController,
                      label: 'Acceptable Min',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _humidityAcceptableMaxController,
                      label: 'Acceptable Max',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildThresholdSection(
            title: 'MQ135 - Air Quality (ppm)',
            icon: Icons.air,
            color: Colors.green,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _mq135GoodController,
                      label: 'Good (≤ value)',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _mq135PoorController,
                      label: 'Poor (> value)',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildThresholdSection(
            title: 'MQ2 - Flammable Gas (ppm)',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _mq2SafeController,
                      label: 'Safe (≤ value)',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _mq2HighController,
                      label: 'High (> value)',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildThresholdSection(
            title: 'MQ7 - Carbon Monoxide (ppm)',
            icon: Icons.warning_amber_rounded,
            color: Colors.red.shade900,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _mq7SafeController,
                      label: 'Safe (≤ value)',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTextField(
                      controller: _mq7HighController,
                      label: 'High (> value)',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveThresholds,
            icon: const Icon(Icons.save),
            label: const Text('Save Thresholds'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: color),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }
}
