import 'package:flutter/material.dart';
import '../models/ai_recommendation.dart';
import '../services/api_service.dart';

class AIRecommendationScreen extends StatefulWidget {
  const AIRecommendationScreen({super.key});

  @override
  State<AIRecommendationScreen> createState() => _AIRecommendationScreenState();
}

class _AIRecommendationScreenState extends State<AIRecommendationScreen> {
  AIRecommendations? _recommendations;
  bool isLoading = true;
  String errorMessage = '';
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await ApiService.getAIRecommendations();
      setState(() {
        _recommendations = AIRecommendations.fromJson(data);
        isLoading = false;
        lastUpdated = DateTime.now();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching recommendations: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - with Wrap for better responsiveness on narrow screens
          LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth > 300 
                ? Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Recommendations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: isLoading ? null : _fetchRecommendations,
                        tooltip: 'Refresh recommendations',
                        iconSize: 20,
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: isLoading ? null : _fetchRecommendations,
                            tooltip: 'Refresh recommendations',
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ],
                  );
            },
          ),
          
          Text(
            'Based on real-time sensor data analysis',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          
          if (lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return constraints.maxWidth < 200
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Last updated:',
                                style: TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              '${lastUpdated?.hour}:${lastUpdated?.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Last updated: ${lastUpdated?.hour}:${lastUpdated?.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                },
              ),
            ),
          
          SizedBox(height: 20),
          
          // Loading State
          if (isLoading)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing greenhouse data...'),
                ],
              ),
            ),
          
          // Error State
          if (!isLoading && errorMessage.isNotEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(errorMessage),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchRecommendations,
                    child: Text('Try Again'),
                  ),
                ],
              ),
            ),
          
          // No Recommendations
          if (!isLoading && errorMessage.isEmpty && 
              (_recommendations == null || _recommendations!.recommendations.isEmpty))
            Center(
              child: Column(
                children: [
                  SizedBox(height: 32),
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'All Parameters Optimal',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your greenhouse conditions are within optimal ranges.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          
          // Recommendations List
          if (!isLoading && _recommendations != null && _recommendations!.recommendations.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _recommendations!.recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = _recommendations!.recommendations[index];
                  return _buildRecommendationCard(recommendation);
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    Color cardColor;
    IconData iconData;
    
    // Set icon and color based on recommendation type
    switch (recommendation.type) {
      case 'temperature':
        cardColor = Colors.orangeAccent.withAlpha((0.2 * 255).round());
        iconData = Icons.thermostat;
        break;
      case 'humidity':
        cardColor = Colors.blueAccent.withAlpha((0.2 * 255).round());
        iconData = Icons.water_drop;
        break;
      case 'co2':
        cardColor = Colors.greenAccent.withAlpha((0.2 * 255).round());
        iconData = Icons.air;
        break;
      default:
        cardColor = Colors.grey.withAlpha((0.2 * 255).round());
        iconData = Icons.eco;
    }
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).cardColor,
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: cardColor.withAlpha(255), width: 5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 250;
              
              return isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          iconData,
                          color: cardColor.withAlpha(255),
                          size: 18,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Text(
                            recommendation.description,
                            style: TextStyle(fontSize: 13),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          iconData,
                          color: cardColor.withAlpha(255),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              recommendation.description,
                              style: TextStyle(fontSize: 13),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
            },
          ),
        ),
      ),
    );
  }
}