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
    
    return Scaffold(
      backgroundColor: beigeBackground,
      appBar: AppBar(
        title: Text('${widget.sensorType} Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalysis,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : _buildAnalysisContent(),
    );
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
        
        // --- REVAMPED: AI Analysis Card ---
        Card(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amber[600]),
                    const SizedBox(width: 12),
                    Text(
                      'AI Analysis',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      Text(
                        aiAnalysis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Generated: ${_formatTimestamp(analysis!.dateTime)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // --- REVAMPED: Recommendations Card ---
        Card(
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Recommendations',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecommendation(),
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
    final gridColor = theme.colorScheme.surface.withOpacity(0.3);

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
              color: chartColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendation() {
    final theme = Theme.of(context);
    String recommendation = '';
    
    // Use a local variable for analysis to ensure null safety
    final currentAnalysis = analysis;
    if (currentAnalysis == null) {
      return const Text("No analysis data to generate recommendations.");
    }

    final type = widget.sensorType.toLowerCase();
    switch (type) {
      case 'temperature':
        if (currentAnalysis.status.toLowerCase() == 'optimal') {
          recommendation = 'Current temperature is optimal for plant growth. Continue maintaining current conditions.';
        } else if (currentAnalysis.status.toLowerCase() == 'acceptable') {
          final isHigh = (currentAnalysis.currentValue as num) > 25;
          recommendation = isHigh
              ? 'Consider increasing ventilation or shading to reduce temperature.'
              : 'Consider increasing heating to raise temperature to optimal range.';
        } else {
          final isHigh = (currentAnalysis.currentValue as num) > 28;
          recommendation = isHigh
              ? 'Temperature is too high! Increase ventilation and shading immediately.'
              : 'Temperature is too low! Increase heating immediately to prevent plant damage.';
        }
        break;
        
      case 'humidity':
        if (currentAnalysis.status.toLowerCase() == 'optimal') {
          recommendation = 'Humidity levels are optimal for most plants. Continue current management.';
        } else if (currentAnalysis.status.toLowerCase() == 'acceptable') {
          final isHigh = (currentAnalysis.currentValue as num) > 70;
          recommendation = isHigh
              ? 'Consider increasing ventilation to reduce humidity levels slightly.'
              : 'Consider using a humidifier or misting plants to raise humidity.';
        } else {
          final isHigh = (currentAnalysis.currentValue as num) > 85;
          recommendation = isHigh
              ? 'Humidity is too high! Increase ventilation to prevent mold and disease.'
              : 'Humidity is too low! Increase humidification to prevent plant stress.';
        }
        break;

      // Air Quality (MQ135)
      case 'air_quality':
      case 'air quality':
      case 'mq135':
        switch (currentAnalysis.status.toLowerCase()) {
          case 'good':
            recommendation = 'Air quality is good. Keep ventilation operating normally to maintain fresh air exchange.';
            break;
          case 'moderate':
            recommendation = 'Air quality is moderate. Increase ventilation, inspect for pollutant sources, and ensure fans/filters are clean.';
            break;
          case 'poor':
          default:
            recommendation = 'Air quality is poor! Immediately increase ventilation, check fans/filters, and investigate sources (e.g., combustion, chemicals). Limit human occupancy until levels improve.';
        }
        break;

      // Flammable Gas / Smoke (MQ2)
      case 'smoke':
      case 'flammable_gas':
      case 'flammable gas':
      case 'mq2':
        switch (currentAnalysis.status.toLowerCase()) {
          case 'safe':
            recommendation = 'No dangerous levels detected. Maintain ventilation and routine leak checks.';
            break;
          case 'elevated':
            recommendation = 'Flammable gas levels are elevated. Improve ventilation, check for leaks, and restrict ignition sources until cleared.';
            break;
          case 'high':
          default:
            recommendation = 'DANGER: Flammable gas at high levels! Evacuate area, shut off gas/compression sources, eliminate ignition sources, and investigate immediately.';
        }
        break;

      // Carbon Monoxide (MQ7)
      case 'co':
      case 'carbon monoxide':
      case 'mq7':
        switch (currentAnalysis.status.toLowerCase()) {
          case 'safe':
            recommendation = 'CO levels are safe. Ensure heating equipment is serviced and detectors are functioning.';
            break;
          case 'elevated':
            recommendation = 'CO levels are elevated. Increase ventilation and inspect combustion appliances and flues immediately.';
            break;
          case 'high':
          default:
            recommendation = 'DANGER: High CO! Evacuate, shut down combustion sources, ventilate aggressively, and seek assistance. Treat exposure symptoms (headache, dizziness) urgently.';
        }
        break;

      // Altitude
      case 'altitude':
        switch (currentAnalysis.status.toLowerCase()) {
          case 'low':
            recommendation = 'Altitude is low (< 500m). Standard greenhouse practices apply. Monitor pressure trends for weather changes.';
            break;
          case 'normal':
            recommendation = 'Altitude is in the normal range (500-1500m). Monitor how elevation affects temperature, humidity, and growing conditions.';
            break;
          case 'high':
          default:
            recommendation = 'Altitude is high (> 1500m). Be aware of reduced air pressure, increased UV exposure, and temperature swings. Adjust ventilation and shading accordingly.';
        }
        break;

      // Pressure
      case 'pressure':
        switch (currentAnalysis.status.toLowerCase()) {
          case 'low':
            recommendation = 'Pressure is low (< 990 hPa). This often indicates stormy or unstable weather. Check ventilation and prepare for possible humidity spikes.';
            break;
          case 'normal':
            recommendation = 'Pressure is normal (990-1030 hPa). Continue monitoring for weather trends that may affect greenhouse conditions.';
            break;
          case 'high':
          default:
            recommendation = 'Pressure is high (> 1030 hPa). This typically indicates clear, stable weather. Monitor temperature for possible heat buildup during sunny periods.';
        }
        break;
        
      default:
        // Use AI analysis if available, otherwise a generic fallback
        recommendation = aiAnalysis.isNotEmpty 
            ? aiAnalysis 
            : 'Monitor this parameter regularly and adjust based on plant requirements.';
    }
    
    return Text(
      recommendation,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.5,
      ),
    );
  }
  
  String _formatTimestamp(DateTime dateTime) {
    // --- FIX: DateFormat is now available ---
    return DateFormat('MMM d, yyyy @ h:mm a').format(dateTime);
  }
}

