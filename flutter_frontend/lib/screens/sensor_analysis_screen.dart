import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
        return Colors.green;
      case 'acceptable':
      case 'moderate':
      case 'adequate':
        return Colors.orange;
      case 'critical':
      case 'poor':
      case 'insufficient':
      case 'high':
        return Colors.red;
      case 'detected':
        return Colors.red;
      case 'safe':
        return Colors.green;
      case 'elevated':
        return Colors.orange;
      case 'bright':
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
  
  double _getLeftInterval(double range) {
    if (range < 5) return 1.0;
    if (range < 20) return 5.0;
    if (range < 100) return range / 5;
    if (range < 500) return range / 4;
    return range / 3;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text('Error: $errorMessage'))
              : _buildAnalysisContent(),
    );
  }
  
  Widget _buildAnalysisContent() {
    if (analysis == null) return const Center(child: Text('No data available'));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Value',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${analysis!.currentValue}',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          analysis!.unit,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Status: '),
                      Chip(
                        label: Text(
                          analysis!.getFormattedStatus(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getStatusColor(analysis!.status),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 4,
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
                        style: Theme.of(context).textTheme.titleMedium,
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
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'AI Analysis',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isLoadingAI)
                    Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Generating AI insights...',
                            style: TextStyle(color: Colors.grey),
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Generated: ${_formatTimestamp(analysis!.dateTime)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
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
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart() {
    if (analysis == null || analysis!.historicalData.isEmpty) {
      return const Center(child: Text('No historical data available'));
    }
    
    final values = analysis!.historicalData.map((dp) => dp.value).toList();
    final timestamps = analysis!.historicalData.map((dp) => dp.timestamp).toList();
    
    if (values.length < 2) {
      return const Center(child: Text('Not enough data points to display chart'));
    }
    
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    final range = maxValue - minValue != 0 ? maxValue - minValue : 1.0;
    
    final yMin = range < 1 ? minValue - 1 : minValue - (range * 0.1);
    final yMax = range < 1 ? maxValue + 1 : maxValue + (range * 0.1);
    
    final timeRange = timestamps.last - timestamps.first;
    final xInterval = timeRange > 0 ? timeRange / 5 : 1.0;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: range / 5,
          verticalInterval: xInterval,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final now = DateTime.now();
                final dataTime = DateTime.fromMillisecondsSinceEpoch((value * 1000).toInt());
                final diff = now.difference(dataTime);
                
                String timeLabel;
                if (diff.inMinutes < 1) {
                  timeLabel = '${diff.inSeconds}s ago';
                } else if (diff.inHours < 1) {
                  timeLabel = '${diff.inMinutes}m ago';
                } else if (diff.inDays < 1) {
                  timeLabel = '${diff.inHours}h ago';
                } else {
                  timeLabel = '${diff.inDays}d ago';
                }
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getLeftInterval(range),
              reservedSize: 80,
              getTitlesWidget: (value, meta) {
                if (widget.sensorType.toLowerCase().contains('flame')) {
                  if (value == 1) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: const Text(
                        'Detected',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  } else if (value == 0) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: const Text(
                        'Not Detected',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
                
                String label;
                if (value.abs() >= 1000) {
                  label = '${(value / 1000).toStringAsFixed(1)}k';
                } else if (value.abs() >= 100) {
                  label = value.toStringAsFixed(0);
                } else if (value.abs() >= 10) {
                  label = value.toStringAsFixed(1);
                } else {
                  label = value.toStringAsFixed(2);
                }
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
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
            color: _getStatusColor(analysis!.status),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: _getStatusColor(analysis!.status),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _getStatusColor(analysis!.status).withAlpha((0.1 * 255).round()),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendation() {
    String recommendation = '';
    
    switch (widget.sensorType.toLowerCase()) {
      case 'temperature':
        if (analysis!.status.toLowerCase() == 'optimal') {
          recommendation = 'Current temperature is optimal for plant growth. Continue maintaining current conditions.';
        } else if (analysis!.status.toLowerCase() == 'acceptable') {
          final isHigh = (analysis!.currentValue as num) > 25;
          recommendation = isHigh
              ? 'Consider increasing ventilation or shading to reduce temperature.'
              : 'Consider increasing heating to raise temperature to optimal range.';
        } else {
          final isHigh = (analysis!.currentValue as num) > 28;
          recommendation = isHigh
              ? 'Temperature is too high! Increase ventilation and shading immediately.'
              : 'Temperature is too low! Increase heating immediately to prevent plant damage.';
        }
        break;
        
      case 'humidity':
        if (analysis!.status.toLowerCase() == 'optimal') {
          recommendation = 'Humidity levels are optimal for most plants. Continue current management.';
        } else if (analysis!.status.toLowerCase() == 'acceptable') {
          final isHigh = (analysis!.currentValue as num) > 70;
          recommendation = isHigh
              ? 'Consider increasing ventilation to reduce humidity levels slightly.'
              : 'Consider using a humidifier or misting plants to raise humidity.';
        } else {
          final isHigh = (analysis!.currentValue as num) > 85;
          recommendation = isHigh
              ? 'Humidity is too high! Increase ventilation to prevent mold and disease.'
              : 'Humidity is too low! Increase humidification to prevent plant stress.';
        }
        break;
        
      case 'co level':
        if ((analysis!.currentValue as num) < 400) {
          recommendation = 'CO levels are below atmospheric average. Check ventilation and consider CO supplementation.';
        } else if ((analysis!.currentValue as num) < 800) {
          recommendation = 'CO levels are within normal range. Consider supplementation during daylight hours for faster growth.';
        } else if ((analysis!.currentValue as num) < 1500) {
          recommendation = 'CO levels are optimal for enhanced plant growth. Continue current management.';
        } else {
          recommendation = 'CO levels are higher than optimal. Check ventilation and adjust supplementation.';
        }
        break;
        
      default:
        recommendation = 'Monitor this parameter regularly and adjust based on plant requirements.';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb, color: Colors.amber),
        const SizedBox(height: 8),
        Text(recommendation),
      ],
    );
  }
  
  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
