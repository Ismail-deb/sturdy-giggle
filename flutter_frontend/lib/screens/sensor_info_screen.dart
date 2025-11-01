import 'package:flutter/material.dart';

class SensorInfoScreen extends StatelessWidget {
  const SensorInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Define all sensors with detailed information
    final sensors = [
      {
        'title': 'Temperature',
        'icon': Icons.thermostat,
        'color': Colors.orange,
        'description': 'Monitors greenhouse air temperature to ensure optimal growing conditions',
        'unit': '°C',
        'optimal': '20-27°C',
        'acceptable': '18-20°C or 27-30°C',
        'critical': '<18°C or >30°C',
        'purpose': 'Temperature is critical for plant metabolism, growth rates, and disease prevention. Most vegetables and greenhouse plants thrive in the 20-27°C range.',
      },
      {
        'title': 'Humidity',
        'icon': Icons.water_drop,
        'color': Colors.blue,
        'description': 'Measures relative humidity levels in the greenhouse air',
        'unit': '%',
        'optimal': '45-70%',
        'acceptable': '71-80%',
        'critical': '<45% or >80%',
        'purpose': 'Proper humidity prevents disease (fungi thrive above 80%), supports healthy transpiration, and reduces plant stress. Controlled through vents and fans.',
      },
      {
        'title': 'Soil Moisture',
        'icon': Icons.grass,
        'color': Colors.brown,
        'description': 'Tracks moisture levels in the growing medium',
        'unit': '%',
        'optimal': '40-60%',
        'acceptable': '30-40% or 60-70%',
        'critical': '<30% or >70%',
        'purpose': 'Ensures plants receive adequate water without overwatering. Different plants have different moisture requirements, but most prefer consistently moist (not saturated) soil.',
      },
      {
        'title': 'Light Level',
        'icon': Icons.wb_sunny,
        'color': Colors.amber,
        'description': 'Monitors ambient light intensity for photosynthesis',
        'unit': 'ADC (0-4095)',
        'optimal': '2458+ (Bright daylight)',
        'acceptable': '1639-2457 (Moderate/Cloudy)',
        'critical': '<820 (Too dim for growth)',
        'purpose': 'Light is essential for photosynthesis and plant growth. Monitors natural sunlight to determine if supplemental lighting is needed.',
      },
      {
        'title': 'CO2 Level',
        'icon': Icons.cloud,
        'color': Colors.purple,
        'description': 'Measures carbon dioxide concentration for plant growth',
        'unit': 'ppm',
        'optimal': '400-1000 ppm',
        'acceptable': '1000-1500 ppm',
        'critical': '>1500 ppm',
        'purpose': 'CO2 is essential for photosynthesis. Elevated levels (up to 1000-1500 ppm) can boost growth rates, but excessive levels reduce air quality.',
      },
      {
        'title': 'Pressure',
        'icon': Icons.compress,
        'color': Colors.indigo,
        'description': 'Barometric pressure context for weather trends and forecasting',
        'unit': 'hPa',
        // No strict action thresholds for pressure in this app
        // Ranges intentionally omitted so the UI hides them gracefully
        'purpose': 'Pressure helps interpret weather changes that can impact humidity, ventilation needs, and transpiration. It is informational and does not trigger alerts on its own.',
      },
      {
        'title': 'Air Quality (MQ135)',
        'icon': Icons.air,
        'color': Colors.green,
        'description': 'MQ135 sensor measures overall air quality and pollutants',
        'unit': 'ppm',
        'optimal': '≤200 ppm (Good)',
        'acceptable': '200-500 ppm (Moderate)',
        'critical': '>500 ppm (Poor)',
        'purpose': 'Detects air quality issues including various gases. Poor air quality triggers ventilation to maintain a healthy environment for plants and workers.',
      },
      {
        'title': 'Smoke Detection (MQ2)',
        'icon': Icons.smoke_free,
        'color': Colors.grey,
        'description': 'MQ2 sensor detects smoke and flammable gases',
        'unit': 'ppm',
        'optimal': '≤300 ppm (Safe)',
        'acceptable': '300-750 ppm (Elevated)',
        'critical': '>750 ppm (DANGER)',
        'purpose': 'Safety sensor that detects combustible gases and smoke. Critical for fire prevention and early warning in greenhouse operations.',
      },
      {
        'title': 'Carbon Monoxide (MQ7)',
        'icon': Icons.warning,
        'color': Colors.deepOrange,
        'description': 'MQ7 sensor specifically monitors CO levels',
        'unit': 'ppm',
        'optimal': '≤300 ppm (Safe)',
        'acceptable': '300-750 ppm (Elevated)',
        'critical': '>750 ppm (DANGER)',
        'purpose': 'Monitors carbon monoxide from heating equipment. Essential safety sensor to prevent CO poisoning and ensure proper heating system operation.',
      },
      {
        'title': 'Flame Detection',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
        'description': 'Optical sensor detects presence of flames',
        'unit': 'Boolean',
        'optimal': 'No flame detected',
        'acceptable': 'N/A',
        'critical': 'Flame detected',
        'purpose': 'Critical safety sensor for immediate fire detection. Provides fastest response to fire hazards in the greenhouse.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Sensors',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            'Learn about each sensor and their optimal ranges',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Sensors List
          Expanded(
            child: ListView.builder(
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: (sensor['color'] as Color).withOpacity(0.1),
                      child: Icon(
                        sensor['icon'] as IconData,
                        color: sensor['color'] as Color,
                      ),
                    ),
                    title: Text(
                      sensor['title'] as String,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      sensor['description'] as String,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showSensorDetails(context, sensor);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSensorDetails(BuildContext context, Map<String, dynamic> sensor) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: (sensor['color'] as Color).withOpacity(0.1),
                        child: Icon(
                          sensor['icon'] as IconData,
                          color: sensor['color'] as Color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sensor['title'] as String,
                              style: theme.textTheme.headlineSmall,
                            ),
                            Text(
                              'Unit: ${sensor['unit']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'About',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sensor['description'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Purpose
                  Text(
                    'Purpose',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sensor['purpose'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  
                  // Optimal Ranges (conditionally rendered)
                  ..._buildRangesSection(context, sensor),
                  const SizedBox(height: 24),
                  
                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRangesSection(BuildContext context, Map<String, dynamic> sensor) {
    final theme = Theme.of(context);
    String? optimal = sensor['optimal'] as String?;
    String? acceptable = sensor['acceptable'] as String?;
    String? critical = sensor['critical'] as String?;

    bool has(String? s) {
      if (s == null) return false;
      final t = s.trim();
      if (t.isEmpty) return false;
      if (t.toLowerCase() == 'n/a') return false;
      if (t.toLowerCase().contains('informational')) return false;
      return true;
    }

    if (!(has(optimal) || has(acceptable) || has(critical))) {
      // No ranges to display for this sensor
      return [];
    }

    return [
      Text(
        'Optimal Ranges',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      if (has(optimal)) _buildRangeCard(context, 'Optimal', optimal!, Colors.green),
      if (has(optimal)) const SizedBox(height: 8),
      if (has(acceptable)) _buildRangeCard(context, 'Acceptable', acceptable!, Colors.orange),
      if (has(acceptable)) const SizedBox(height: 8),
      if (has(critical)) _buildRangeCard(context, 'Critical', critical!, Colors.red),
    ];
  }

  Widget _buildRangeCard(BuildContext context, String label, String range, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  range,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
