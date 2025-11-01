import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// --- FIX: Added intl package import ---
import 'package:intl/intl.dart';
// -------------------------------------
import '../models/sensor_analysis.dart';
import '../services/api_service.dart';

class SensorAnalysisScreen extends StatefulWidget {
  final String sensorType;
  
  const SensorAnalysisScreen({
    super.key,
    required this.sensorType,
  });

  @override
  State<SensorAnalysisScreen> createState() => _SensorAnalysisScreenState();
}

class _SensorAnalysisScreenState extends State<SensorAnalysisScreen> {
  bool isLoading = true;
  bool isLoadingAI = true;
  String errorMessage = '';
  SensorAnalysis? analysis;
  String aiAnalysis = '';
  String selectedTimeRange = 'hours';
  
  final List<Map<String, String>> timeRanges = [
    {'value': 'seconds', 'label': 'Last Minute'},
    {'value': 'minutes', 'label': 'Last Hour'},
    {'value': 'hours', 'label': 'Last Day'},
    {'value': 'days', 'label': 'Last Month'},
    {'value': 'weeks', 'label': 'Last Year (Weekly)'},
    {'value': 'months', 'label': 'Last Year (Monthly)'},
    {'value': 'years', 'label': 'Last 5 Years'},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadAnalysis();
    _loadAIAnalysis();
  }
  
  Future<void> _loadAnalysis() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final data = await ApiService.getSensorAnalysis(
        widget.sensorType,
        timeRange: selectedTimeRange,
        includeAI: false
      );
      
      setState(() {
        analysis = SensorAnalysis.fromJson(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  
  Future<void> _loadAIAnalysis() async {
    if (!mounted) return;  // Check if widget is still mounted
    
    setState(() {
      isLoadingAI = true;
    });
    
    try {
      final aiData = await ApiService.getSensorAIAnalysis(widget.sensorType);
      
      if (!mounted) return;  // Check again before calling setState
      
      setState(() {
        aiAnalysis = aiData['analysis'] ?? 'AI analysis not available';
        isLoadingAI = false;
      });
    } catch (e) {
      if (!mounted) return;  // Check again before calling setState
      
      setState(() {
        aiAnalysis = 'AI analysis temporarily unavailable';
        isLoadingAI = false;
      });
    }
  }
  
  void _onTimeRangeChanged(String? newValue) {
    if (newValue != null && newValue != selectedTimeRange) {
      setState(() {
        selectedTimeRange = newValue;
      });
      _loadAnalysis();
      _loadAIAnalysis();
    }
  }

  Color _getStatusColor(String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
      case 'safe':
      case 'bright':
      case 'moderate':
      case 'none': // For flame
        return scheme.primary;
      case 'acceptable':
      case 'elevated':
      case 'dim indoor':
        return Colors.orangeAccent;
      case 'critical':
      case 'high':
      case 'poor':
      case 'low light':
      case 'dark night':
      case 'detected': // For flame
        return Colors.redAccent;
      default:
        return scheme.secondary;
    }
  }
  
  double _getLeftInterval(double range) {
    if (range <= 0) return 1.0;
    if (range < 5) return 1.0;
    if (range < 20) return 5.0;
    if (range < 100) return (range / 5).ceilToDouble();
    if (range < 500) return (range / 4).ceilToDouble();
    return (range / 3).ceilToDouble();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final beigeBackground = isDarkMode 
        ? theme.scaffoldBackgroundColor // Keep dark theme unchanged
        : const Color(0xFFF5E6D3); // Warm beige for light theme
    
    // Get icon and color based on sensor type
    IconData sensorIcon;
    Color iconColor;
    String displayName = _getSensorDisplayName();
    
    final st = widget.sensorType.toLowerCase();
    if (st.contains('temp')) {
      sensorIcon = Icons.thermostat;
      iconColor = Colors.deepOrange;
    } else if (st.contains('humid')) {
      sensorIcon = Icons.water_drop;
      iconColor = Colors.blue;
    } else if (st.contains('co2') || st.contains('air')) {
      sensorIcon = Icons.air;
      iconColor = Colors.teal;
    } else if (st.contains('light')) {
      sensorIcon = Icons.light_mode;
      iconColor = Colors.amber;
    } else if (st.contains('soil') || st.contains('moisture')) {
      sensorIcon = Icons.grass;
      iconColor = Colors.brown;
    } else if (st.contains('smoke') || st.contains('mq2') || st.contains('flammable')) {
      sensorIcon = Icons.smoke_free;
      iconColor = Colors.deepOrange;
    } else if (st.contains('mq7') || st.contains('carbon monoxide')) {
      sensorIcon = Icons.warning_amber;
      iconColor = Colors.red;
    } else if (st.contains('flame')) {
      sensorIcon = Icons.local_fire_department;
      iconColor = Colors.redAccent;
    } else if (st.contains('pressure')) {
      sensorIcon = Icons.compress;
      iconColor = Colors.indigo;
    } else if (st.contains('altitude')) {
      sensorIcon = Icons.landscape;
      iconColor = Colors.green;
    } else {
      sensorIcon = Icons.sensors;
      iconColor = theme.colorScheme.primary;
    }
    
    return Scaffold(
      backgroundColor: beigeBackground,
      appBar: AppBar(
        backgroundColor: beigeBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                sensorIcon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () {
              _loadAnalysis();
              _loadAIAnalysis();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : _buildAnalysisContent(),
    );
  }
  
  String _getSensorDisplayName() {
    final st = widget.sensorType.toLowerCase();
    if (st.contains('temp')) return 'Temperature';
    if (st.contains('humid')) return 'Humidity';
    if (st.contains('co2') || st.contains('air_quality')) return 'CO₂ & Air Quality';
    if (st.contains('light')) return 'Light Intensity';
    if (st.contains('soil') || st.contains('moisture')) return 'Soil Moisture';
    if (st.contains('smoke') || st.contains('mq2') || st.contains('flammable')) return 'Flammable Gas';
    if (st.contains('mq7') || st.contains('carbon monoxide')) return 'Carbon Monoxide';
    if (st.contains('flame')) return 'Flame Detection';
    if (st.contains('pressure')) return 'Atmospheric Pressure';
    if (st.contains('altitude')) return 'Altitude';
    // Capitalize first letter of each word
    return widget.sensorType.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
  
  Widget _buildAnalysisContent() {
    if (analysis == null) return const Center(child: Text('No data available'));
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(analysis!.status);
    
    // Custom card color for light theme - soft cream that complements beige
    final cardColor = isDarkMode 
        ? theme.colorScheme.surface // Keep dark theme unchanged
        : const Color(0xFFFFFAF0); // Soft cream/ivory color
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- REVAMPED: Current Value Card ---
        Card(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${analysis!.currentValue}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              analysis!.unit,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                     Text(
                        'Status',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          analysis!.getFormattedStatus(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // --- REVAMPED: Historical Data Card ---
        Card(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Historical Data',
                      style: theme.textTheme.titleLarge,
                    ),
                    DropdownButton<String>(
                      value: selectedTimeRange,
                      onChanged: _onTimeRangeChanged,
                      items: timeRanges.map((range) {
                        return DropdownMenuItem<String>(
                          value: range['value'],
                          child: Text(range['label']!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: _buildChart(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // --- COMBINED: AI Analysis & Recommendations Card ---
        Card(
          color: cardColor,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber[600]?.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_awesome, color: Colors.amber[600], size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI Analysis & Recommendations',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Refresh button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      color: theme.colorScheme.primary,
                      tooltip: 'Refresh AI Analysis',
                      onPressed: isLoadingAI ? null : _loadAIAnalysis,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // AI Analysis Section
                if (isLoadingAI)
                  Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Generating AI insights...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Analysis header
                      Row(
                        children: [
                          Icon(Icons.analytics_outlined, 
                            color: theme.colorScheme.primary, 
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Analysis',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withAlpha((0.5 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber[600]!.withAlpha((0.3 * 255).round()),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          aiAnalysis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Recommendations header
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, 
                            color: theme.colorScheme.primary, 
                            size: 20
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recommendations',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha((0.3 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha((0.3 * 255).round()),
                            width: 1,
                          ),
                        ),
                        child: _buildRecommendation(),
                      ),
                      const SizedBox(height: 16),
                      
                      // Timestamp at the bottom
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Generated: ${_formatTimestamp(analysis!.dateTime)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChart() {
    if (analysis == null || analysis!.historicalData.isEmpty) {
      return const Center(child: Text('No historical data available'));
    }
    
    final theme = Theme.of(context);
    final values = analysis!.historicalData.map((dp) => dp.value).toList();
    final timestamps = analysis!.historicalData.map((dp) => dp.timestamp).toList();
    
    if (values.length < 2) {
      return const Center(child: Text('Not enough data points to display chart'));
    }
    
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    final range = maxValue - minValue;
    
    final yMin = range < 1 ? minValue - 1 : minValue - (range * 0.2);
    final yMax = range < 1 ? maxValue + 1 : maxValue + (range * 0.2);
    
    final timeRange = timestamps.last - timestamps.first;
    final xInterval = timeRange > 0 ? timeRange / 5 : 1.0;
    
    final chartColor = _getStatusColor(analysis!.status);
  final gridColor = theme.colorScheme.surface.withAlpha((0.3 * 255).round());

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getLeftInterval(range),
          verticalInterval: xInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: gridColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: gridColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final dt = DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
                String timeLabel;
                // --- FIX: DateFormat is now available ---
                if(selectedTimeRange == 'seconds' || selectedTimeRange == 'minutes') {
                  timeLabel = DateFormat.Hms().format(dt);
                } else if (selectedTimeRange == 'hours') {
                  timeLabel = DateFormat.Hm().format(dt);
                } else {
                  timeLabel = DateFormat.Md().format(dt);
                }
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _getLeftInterval(range),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    value.toStringAsFixed(0),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: gridColor, width: 1),
        ),
        minX: timestamps.first,
        maxX: timestamps.last,
        minY: yMin,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (index) => FlSpot(
                timestamps[index],
                values[index],
              ),
            ),
            isCurved: true,
            color: chartColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: chartColor.withAlpha((0.2 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendation() {
    final theme = Theme.of(context);
    List<String> recommendations = [];
    IconData recommendationIcon = Icons.info_outline;
    Color recommendationColor = theme.colorScheme.primary;
    
    // Use a local variable for analysis to ensure null safety
    final currentAnalysis = analysis;
    if (currentAnalysis == null) {
      return const Text("No analysis data to generate recommendations.");
    }

    final type = widget.sensorType.toLowerCase();
    final status = currentAnalysis.status.toLowerCase();
    
    switch (type) {
      case 'temperature':
        if (status == 'optimal') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'Current temperature is optimal for plant growth',
            'Continue maintaining current climate control settings',
            'Monitor for any sudden changes in weather',
          ];
        } else if (status == 'acceptable') {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          final isHigh = (currentAnalysis.currentValue as num) > 25;
          recommendations = isHigh
              ? [
                  'Temperature is slightly elevated',
                  'Increase ventilation or activate cooling systems',
                  'Consider adding shading during peak sun hours',
                  'Ensure fans and air circulation are optimal',
                ]
              : [
                  'Temperature is slightly below optimal',
                  'Increase heating to raise temperature gradually',
                  'Check for drafts or cold air leaks',
                  'Consider supplemental heating during cold periods',
                ];
        } else {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.red;
          final isHigh = (currentAnalysis.currentValue as num) > 28;
          recommendations = isHigh
              ? [
                  '⚠️ Temperature is critically high!',
                  'IMMEDIATE ACTION: Increase ventilation to maximum',
                  'Activate all cooling systems and shading',
                  'Monitor plants for heat stress symptoms',
                  'Consider misting to reduce temperature',
                ]
              : [
                  '⚠️ Temperature is critically low!',
                  'IMMEDIATE ACTION: Increase heating systems',
                  'Close vents and seal any cold air entry points',
                  'Monitor plants for cold damage',
                  'Consider emergency heating if available',
                ];
        }
        break;
        
      case 'humidity':
        if (status == 'optimal') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'Humidity levels are optimal for healthy plant growth',
            'Continue current humidity management practices',
            'Monitor for seasonal changes',
          ];
        } else if (status == 'acceptable') {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          final isHigh = (currentAnalysis.currentValue as num) > 70;
          recommendations = isHigh
              ? [
                  'Humidity is slightly elevated',
                  'Increase ventilation to reduce moisture',
                  'Check for water leaks or excessive watering',
                  'Monitor plants for fungal issues',
                ]
              : [
                  'Humidity is slightly below optimal',
                  'Use humidifiers or misting systems',
                  'Group plants together to increase local humidity',
                  'Check irrigation systems are functioning',
                ];
        } else {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.red;
          final isHigh = (currentAnalysis.currentValue as num) > 85;
          recommendations = isHigh
              ? [
                  '⚠️ Humidity is critically high!',
                  'IMMEDIATE ACTION: Maximize ventilation',
                  'Check for water leaks or flooding',
                  'Inspect plants for mold, mildew, or rot',
                  'Consider dehumidification systems',
                ]
              : [
                  '⚠️ Humidity is critically low!',
                  'IMMEDIATE ACTION: Increase humidification',
                  'Check all watering and misting systems',
                  'Monitor plants for wilting or leaf curl',
                  'Consider emergency misting',
                ];
        }
        break;

      // Air Quality (MQ135) + CO₂
      case 'air_quality':
      case 'air quality':
      case 'mq135':
      case 'co2':
      case 'co₂':
        if (status == 'optimal') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'Air quality and CO₂ levels are optimal',
            'Continue normal ventilation operations',
            'Maintain current air exchange rates',
          ];
        } else if (status == 'good') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.lightGreen;
          recommendations = [
            'Air quality is good with acceptable CO₂ levels',
            'Keep ventilation systems running smoothly',
            'Monitor for any changes in air composition',
          ];
        } else if (status == 'moderate') {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          recommendations = [
            'Air quality is moderate - improvement needed',
            'Increase ventilation to improve air exchange',
            'Check for pollutant sources (dust, chemicals, etc.)',
            'Ensure all fans and filters are clean and operational',
            'Consider CO₂ supplementation if levels are low',
          ];
        } else if (status == 'high') {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.deepOrange;
          recommendations = [
            '⚠️ Air quality is concerning!',
            'IMMEDIATE ACTION: Increase ventilation significantly',
            'Inspect for combustion or chemical sources',
            'Check air filters and replace if needed',
            'Verify CO₂ enrichment systems are not over-dosing',
            'Consider reducing occupancy until improved',
          ];
        } else {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.red;
          recommendations = [
            '⚠️ CRITICAL: Air quality is poor!',
            'IMMEDIATE ACTION: Maximize all ventilation',
            'Evacuate personnel if necessary',
            'Shut down any CO₂ enrichment systems',
            'Investigate all potential pollutant sources',
            'Do not re-occupy until levels normalize',
          ];
        }
        break;

      // Flammable Gas / Smoke (MQ2)
      case 'smoke':
      case 'flammable_gas':
      case 'flammable gas':
      case 'mq2':
        if (status == 'safe') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'No dangerous levels detected',
            'Maintain regular ventilation',
            'Continue routine gas leak inspections',
          ];
        } else if (status == 'elevated') {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          recommendations = [
            'Flammable gas levels are elevated',
            'Improve ventilation immediately',
            'Check for gas leaks in all connections',
            'Restrict ignition sources (sparks, flames, etc.)',
            'Monitor levels closely until cleared',
          ];
        } else {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.red;
          recommendations = [
            '⚠️ DANGER: Flammable gas at HIGH levels!',
            'EVACUATE AREA IMMEDIATELY',
            'Shut off all gas sources and compression systems',
            'Eliminate all ignition sources',
            'Call emergency services if needed',
            'Do not re-enter until gas levels are safe',
          ];
        }
        break;

      // Carbon Monoxide (MQ7)
      case 'co':
      case 'carbon monoxide':
      case 'mq7':
        if (status == 'safe') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'CO levels are safe',
            'Ensure heating equipment is regularly serviced',
            'Verify CO detectors are functioning properly',
          ];
        } else if (status == 'elevated') {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          recommendations = [
            'CO levels are elevated',
            'Increase ventilation immediately',
            'Inspect all combustion appliances',
            'Check flues and exhaust systems',
          ];
        } else {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.red;
          recommendations = [
            '⚠️ DANGER: High CO levels!',
            'EVACUATE AREA IMMEDIATELY',
            'Shut down all combustion sources',
            'Ventilate aggressively',
            'Seek medical attention for exposure symptoms',
          ];
        }
        break;

      // Soil Moisture
      case 'soil_moisture':
      case 'soil moisture':
      case 'moisture':
        if (status == 'optimal') {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'Soil moisture is at optimal levels',
            'Continue current watering schedule',
            'Monitor for any changes in drainage',
          ];
        } else if (status == 'low' || status.contains('low')) {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          recommendations = [
            'Soil moisture is low',
            'Increase watering frequency or duration',
            'Check irrigation system for issues',
            'Consider mulching to retain moisture',
            'Monitor plants for wilting',
          ];
        } else {
          recommendationIcon = Icons.error_outline;
          recommendationColor = Colors.red;
          recommendations = [
            '⚠️ Soil moisture is critically ${status.contains("high") ? "high" : "low"}!',
            status.contains("high")
                ? 'Reduce watering immediately'
                : 'Increase watering urgently',
            status.contains("high")
                ? 'Check for drainage problems or overwatering'
                : 'Check irrigation system functionality',
            status.contains("high")
                ? 'Monitor for root rot symptoms'
                : 'Watch for severe wilting or leaf drop',
          ];
        }
        break;

      // Light
      case 'light':
      case 'light_intensity':
        if (status.contains('moderate') || status.contains('optimal')) {
          recommendationIcon = Icons.check_circle_outline;
          recommendationColor = Colors.green;
          recommendations = [
            'Light levels are suitable for plant growth',
            'Maintain current lighting conditions',
            'Monitor for seasonal light changes',
          ];
        } else if (status.contains('low') || status.contains('dim')) {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          recommendations = [
            'Light levels are low',
            'Consider supplemental grow lights',
            'Clean greenhouse panels to maximize light',
            'Adjust plant positioning for better exposure',
          ];
        } else if (status.contains('bright')) {
          recommendationIcon = Icons.warning_amber_outlined;
          recommendationColor = Colors.orange;
          recommendations = [
            'Light levels are very bright',
            'Consider shade cloth during peak hours',
            'Monitor plants for sun stress or bleaching',
            'Increase ventilation to manage heat',
          ];
        } else {
          recommendationIcon = Icons.info_outline;
          recommendationColor = theme.colorScheme.primary;
          recommendations = [
            'Monitor light levels regularly',
            'Adjust based on plant requirements',
          ];
        }
        break;
        
      default:
        // Generic recommendation
        recommendationIcon = Icons.info_outline;
        recommendationColor = theme.colorScheme.primary;
        recommendations = [
          'Monitor this parameter regularly',
          'Adjust conditions based on plant requirements',
          'Consult with agricultural specialists if needed',
        ];
    }
    
    // Return formatted recommendations as bullet points
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recommendations.map((rec) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4.0, right: 12.0),
                child: Icon(
                  recommendationIcon,
                  size: 18,
                  color: recommendationColor,
                ),
              ),
              Expanded(
                child: Text(
                  rec,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontWeight: rec.startsWith('⚠️') || rec.contains('IMMEDIATE') || rec.contains('DANGER') || rec.contains('EVACUATE')
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: rec.startsWith('⚠️') || rec.contains('IMMEDIATE') || rec.contains('DANGER') || rec.contains('EVACUATE')
                        ? recommendationColor
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  String _formatTimestamp(DateTime dateTime) {
    // --- FIX: DateFormat is now available ---
    return DateFormat('MMM d, yyyy @ h:mm a').format(dateTime);
  }
}

