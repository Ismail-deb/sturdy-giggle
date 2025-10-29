import 'package:flutter/material.dart';
import './threshold_settings_screen.dart';

class SensorInfoScreen extends StatelessWidget {
  const SensorInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Information & Troubleshooting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThresholdSettingsScreen()),
              );
            },
            tooltip: 'Configure Thresholds',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSensorCard(
            context,
            title: 'Temperature Sensors',
            icon: Icons.thermostat,
            color: Colors.red,
            description: 'BMP280 & DHT22 measure greenhouse temperature',
            optimalRange: '21-27°C',
            acceptableRange: '18-30°C',
            troubleshooting: [
              'Check sensor connection to controller',
              'Verify sensor is not in direct sunlight',
              'Ensure sensor is not near heating/cooling vents',
              'Clean dust from sensor housing',
              'Replace sensor if readings are erratic',
            ],
            tips: [
              'Average of both sensors used for accuracy',
              'BMP280 more accurate, DHT22 backup',
              'Calibrate sensors quarterly',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'Humidity Sensor (DHT22)',
            icon: Icons.water_drop,
            color: Colors.blue,
            description: 'Measures relative humidity in greenhouse',
            optimalRange: '60-75%',
            acceptableRange: '50-85%',
            troubleshooting: [
              'Check if sensor is exposed to moisture',
              'Verify sensor wiring is not damaged',
              'Ensure sensor is in well-ventilated area',
              'Clean sensor with dry cloth (not wet)',
              'Replace if readings stuck at 0% or 100%',
            ],
            tips: [
              'Control via vents and fans',
              'Close vents to increase humidity',
              'Open vents/run fans to decrease humidity',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'MQ135 - Air Quality Sensor',
            icon: Icons.air,
            color: Colors.green,
            description: 'Detects air quality and CO2-like gases',
            optimalRange: '≤200 ppm',
            acceptableRange: '200-500 ppm',
            troubleshooting: [
              'Allow 24-48 hours warm-up for new sensor',
              'Check if sensor needs recalibration in clean air',
              'Verify baseline value is recorded correctly',
              'Ensure sensor is not blocked or covered',
              'Replace if readings always show high values',
            ],
            tips: [
              'Measures voltage drop from baseline',
              'Lower drop = cleaner air',
              'Higher drop = more pollutants/CO2',
              'Increase ventilation when >200 ppm',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'MQ2 - Flammable Gas Sensor',
            icon: Icons.local_fire_department,
            color: Colors.orange,
            description: 'Detects smoke and combustible gases (LPG, propane)',
            optimalRange: '≤300 ppm',
            acceptableRange: '300-750 ppm (CAUTION)',
            troubleshooting: [
              'CRITICAL: >750 ppm requires immediate action',
              'Check all gas connections for leaks',
              'Inspect fuel lines and tanks',
              'Verify heating equipment is functioning properly',
              'Test sensor with lighter flame (brief exposure)',
              'Replace sensor every 2-3 years',
            ],
            tips: [
              'Never ignore high readings',
              'Increase ventilation if elevated',
              'Keep fire extinguisher accessible',
              'Regular maintenance prevents false alarms',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'MQ7 - Carbon Monoxide Sensor',
            icon: Icons.warning_amber_rounded,
            color: Colors.red.shade900,
            description: 'Detects deadly carbon monoxide gas',
            optimalRange: '≤300 ppm',
            acceptableRange: '300-750 ppm (WARNING)',
            troubleshooting: [
              'DANGER: >750 ppm is life-threatening',
              'Check all combustion equipment immediately',
              'Inspect heating system and exhausts',
              'Ensure proper ventilation at all times',
              'Test sensor monthly with CO test gas',
              'Replace sensor annually for safety',
            ],
            tips: [
              'CO is colorless, odorless, deadly',
              'Always ventilate when levels rise',
              'Never run generators indoors',
              'Install backup CO detector recommended',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'Flame Sensor (IR Detection)',
            icon: Icons.whatshot,
            color: Colors.deepOrange,
            description: 'Detects flames and strong infrared sources',
            optimalRange: 'No detection',
            acceptableRange: 'N/A - Alert on detection',
            troubleshooting: [
              'Check sensor lens for dirt or obstructions',
              'Verify sensor angle covers heating equipment',
              'Test with lighter flame to confirm sensitivity',
              'Adjust sensor position if getting false positives',
              'Shield from direct sunlight (causes false positives)',
              'Replace if unresponsive to flame',
            ],
            tips: [
              'Detects IR wavelength from flames',
              'Lower raw value = flame detected',
              'Immediate inspection required on alert',
              'Position near potential fire sources',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'BMP280 - Pressure & Altitude',
            icon: Icons.speed,
            color: Colors.purple,
            description: 'Measures barometric pressure and calculates altitude',
            optimalRange: '990-1030 hPa',
            acceptableRange: '950-1050 hPa',
            troubleshooting: [
              'Check I2C connection to controller',
              'Verify sensor address is correct (0x76 or 0x77)',
              'Ensure sensor is not in sealed container',
              'Calibrate for local altitude if needed',
              'Replace if readings are frozen',
            ],
            tips: [
              'Pressure changes indicate weather patterns',
              'Falling pressure = storm approaching',
              'Rising pressure = improving weather',
              'Minimal impact on plant growth directly',
            ],
          ),
          _buildSensorCard(
            context,
            title: 'Light Sensor (Photoresistor)',
            icon: Icons.wb_sunny,
            color: Colors.amber,
            description: 'Measures ambient light levels',
            optimalRange: '40-80% (varies by plant)',
            acceptableRange: '20-100%',
            troubleshooting: [
              'Check if sensor is covered or shadowed',
              'Verify ADC reading is changing with light',
              'Clean sensor surface from dust',
              'Recalibrate min/max values if needed',
              'Replace if readings stuck at one value',
            ],
            tips: [
              'Higher raw value = more light',
              'Position to represent average light',
              'Supplement with grow lights if low',
              'Different plants need different light levels',
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade700,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'General Troubleshooting Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTipItem('Always power off system before touching sensors'),
                  _buildTipItem('Document baseline values when sensors are new'),
                  _buildTipItem('Regular maintenance schedule prevents issues'),
                  _buildTipItem('Keep spare sensors for critical measurements'),
                  _buildTipItem('Test sensors individually to isolate problems'),
                  _buildTipItem('Check wiring and connections first - most common issue'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency Response',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEmergencyItem('Flame Detected', 'Evacuate and call fire department'),
                  _buildEmergencyItem('CO >750 ppm', 'Ventilate immediately, evacuate area'),
                  _buildEmergencyItem('Gas >750 ppm', 'No sparks/flames, ventilate, check for leaks'),
                  _buildEmergencyItem('Temp >35°C', 'Emergency cooling, protect plants'),
                  _buildEmergencyItem('Temp <10°C', 'Emergency heating, cover sensitive plants'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required String optimalRange,
    required String acceptableRange,
    required List<String> troubleshooting,
    required List<String> tips,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Optimal Range', optimalRange, Colors.green),
                const SizedBox(height: 8),
                _buildInfoRow('Acceptable Range', acceptableRange, Colors.orange),
                const Divider(height: 24),
                const Text(
                  'Troubleshooting Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ...troubleshooting.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                const Text(
                  'Tips & Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tip)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(String condition, String action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$condition: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: action),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
