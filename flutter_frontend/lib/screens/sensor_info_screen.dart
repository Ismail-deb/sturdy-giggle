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
        'unit': 'Status',
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
          // Header with modern styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sensors_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sensor Guide',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Learn about each sensor and their optimal ranges',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Sensors List with modern cards
          Expanded(
            child: ListView.builder(
              itemCount: sensors.length,
              itemBuilder: (context, index) {
                final sensor = sensors[index];
                final sensorColor = sensor['color'] as Color;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: sensorColor.withValues(alpha: 0.2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showSensorDetails(context, sensor),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              sensorColor.withValues(alpha: 0.05),
                              sensorColor.withValues(alpha: 0.02),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sensorColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    sensorColor.withValues(alpha: 0.2),
                                    sensorColor.withValues(alpha: 0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: sensorColor.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                sensor['icon'] as IconData,
                                color: sensorColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sensor['title'] as String,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sensor['description'] as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Unit badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sensorColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Unit: ${sensor['unit']}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: sensorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Arrow icon
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: sensorColor.withValues(alpha: 0.5),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
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
    final sensorColor = sensor['color'] as Color;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient background
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        sensorColor.withValues(alpha: 0.15),
                        sensorColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              sensorColor.withValues(alpha: 0.3),
                              sensorColor.withValues(alpha: 0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: sensorColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          sensor['icon'] as IconData,
                          color: sensorColor,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sensor['title'] as String,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: sensorColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Unit: ${sensor['unit']}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: sensorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description section
                      _buildInfoSection(
                        context,
                        'About',
                        sensor['description'] as String,
                        Icons.info_outline_rounded,
                        sensorColor,
                      ),
                      const SizedBox(height: 20),
                      
                      // Purpose section
                      _buildInfoSection(
                        context,
                        'Purpose',
                        sensor['purpose'] as String,
                        Icons.lightbulb_outline_rounded,
                        sensorColor,
                      ),
                      const SizedBox(height: 24),
                      
                      // Optimal Ranges (conditionally rendered)
                      ..._buildRangesSection(context, sensor, sensorColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRangesSection(
    BuildContext context,
    Map<String, dynamic> sensor,
    Color sensorColor,
  ) {
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
      return [];
    }

    return [
      Row(
        children: [
          Icon(
            Icons.speed_rounded,
            size: 20,
            color: sensorColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Optimal Ranges',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: sensorColor,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      if (has(optimal)) _buildRangeCard(context, 'Optimal', optimal!, Colors.green),
      if (has(optimal)) const SizedBox(height: 12),
      if (has(acceptable)) _buildRangeCard(context, 'Acceptable', acceptable!, Colors.orange),
      if (has(acceptable)) const SizedBox(height: 12),
      if (has(critical)) _buildRangeCard(context, 'Critical', critical!, Colors.red),
    ];
  }

  Widget _buildRangeCard(BuildContext context, String label, String range, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              label == 'Optimal'
                  ? Icons.check_circle_rounded
                  : label == 'Acceptable'
                      ? Icons.info_rounded
                      : Icons.warning_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  range,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
