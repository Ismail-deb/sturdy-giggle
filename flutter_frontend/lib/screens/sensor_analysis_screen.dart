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
  String selectedChartType = 'line'; // Default chart type
  
  final List<Map<String, String>> timeRanges = [
    {'value': 'seconds', 'label': 'Last Minute'},
    {'value': 'minutes', 'label': 'Last Hour'},
    {'value': 'hours', 'label': 'Last Day'},
    {'value': 'days', 'label': 'Last Month'},
    {'value': 'weeks', 'label': 'Last Year (Weekly)'},
    {'value': 'months', 'label': 'Last Year (Monthly)'},
    {'value': 'years', 'label': 'Last 5 Years'},
  ];
  
  final List<Map<String, dynamic>> chartTypes = [
    {'value': 'line', 'label': 'Line Chart', 'icon': Icons.show_chart_rounded},
    {'value': 'bar', 'label': 'Bar Chart', 'icon': Icons.bar_chart_rounded},
    {'value': 'area', 'label': 'Area Chart', 'icon': Icons.area_chart_rounded},
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
        ? theme.scaffoldBackgroundColor
        : const Color(0xFFF5E6D3);
    
    return Scaffold(
      backgroundColor: beigeBackground,
      appBar: AppBar(
        title: Text(
          '${widget.sensorType} Analysis',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadAnalysis,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading sensor analysis...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading Data',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _loadAnalysis,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _buildAnalysisContent(),
    );
  }
  
  Widget _buildAnalysisContent() {
    if (analysis == null) return const Center(child: Text('No data available'));
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(analysis!.status);
    
    final cardColor = isDarkMode 
        ? theme.colorScheme.surface
        : const Color(0xFFFFFAF0);
    
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Hero Value Card with gradient and elevation
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.15),
                statusColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Card(
            color: cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: statusColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Reading',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${analysis!.currentValue}',
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 48,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  analysis!.unit,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Status',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              analysis!.getFormattedStatus(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Historical Data Card with modern design
        Card(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.show_chart_rounded,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Historical Trend',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: selectedTimeRange,
                        onChanged: _onTimeRangeChanged,
                        underline: const SizedBox(),
                        isDense: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        items: timeRanges.map((range) {
                          return DropdownMenuItem<String>(
                            value: range['value'],
                            child: Text(range['label']!),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chart type selector with icon buttons
                Row(
                  children: [
                    Text(
                      'Chart Type:',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ...chartTypes.map((type) {
                      final isSelected = selectedChartType == type['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                size: 16,
                                color: isSelected 
                                    ? Colors.white 
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected 
                                      ? Colors.white 
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedChartType = type['value'] as String;
                              });
                            }
                          },
                          selectedColor: theme.colorScheme.primary,
                          checkmarkColor: Colors.white,
                          backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          side: BorderSide(
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 280,
                  child: _buildChart(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // AI Analysis Card with premium styling
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.08),
                Colors.orange.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Card(
            color: cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: Colors.amber.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          color: Colors.amber[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI Insights',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isLoadingAI)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Analyzing sensor data with AI...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            aiAnalysis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.7,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Generated: ${_formatTimestamp(analysis!.dateTime)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Recommendations Card with modern design
        Card(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tips_and_updates_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Expert Recommendations',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: _buildRecommendation(),
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
    final gridColor = theme.colorScheme.surface.withOpacity(0.3);

    // Return different chart types based on selection
    switch (selectedChartType) {
      case 'bar':
        return _buildBarChart(timestamps, values, chartColor, gridColor, yMin, yMax, xInterval, range);
      case 'area':
        return _buildAreaChart(timestamps, values, chartColor, gridColor, yMin, yMax, xInterval, range);
      case 'line':
      default:
        return _buildLineChart(timestamps, values, chartColor, gridColor, yMin, yMax, xInterval, range);
    }
  }

  Widget _buildLineChart(List<double> timestamps, List<double> values, Color chartColor, Color gridColor, double yMin, double yMax, double xInterval, double range) {
    final theme = Theme.of(context);
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
        titlesData: _buildTitlesData(xInterval, range, theme),
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
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: values.length < 20,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: chartColor,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> timestamps, List<double> values, Color chartColor, Color gridColor, double yMin, double yMax, double xInterval, double range) {
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getLeftInterval(range),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: gridColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: _buildTitlesData(xInterval, range, theme),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: gridColor, width: 1),
            bottom: BorderSide(color: gridColor, width: 1),
          ),
        ),
        minY: yMin,
        maxY: yMax,
        barGroups: List.generate(
          values.length,
          (index) => BarChartGroupData(
            x: timestamps[index].toInt(),
            barRods: [
              BarChartRodData(
                toY: values[index],
                color: chartColor,
                width: values.length > 50 ? 4 : 12,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: yMax,
                  color: gridColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAreaChart(List<double> timestamps, List<double> values, Color chartColor, Color gridColor, double yMin, double yMax, double xInterval, double range) {
    final theme = Theme.of(context);
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
        titlesData: _buildTitlesData(xInterval, range, theme),
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
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  chartColor.withOpacity(0.5),
                  chartColor.withOpacity(0.1),
                  chartColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  FlTitlesData _buildTitlesData(double xInterval, double range, ThemeData theme) {
    return FlTitlesData(
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
        height: 1.7,
        fontSize: 15,
      ),
    );
  }
  
  String _formatTimestamp(DateTime dateTime) {
    // --- FIX: DateFormat is now available ---
    return DateFormat('MMM d, yyyy @ h:mm a').format(dateTime);
  }
}