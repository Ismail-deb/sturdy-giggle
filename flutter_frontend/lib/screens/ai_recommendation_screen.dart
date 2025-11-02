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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Dashboard',
        ),
        title: const Text(
          'AI Recommendations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.withOpacity(0.1),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isLoading ? Icons.hourglass_empty_rounded : Icons.refresh_rounded,
              color: Colors.amber[700],
            ),
            onPressed: isLoading ? null : _fetchRecommendations,
            tooltip: 'Refresh recommendations',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header Card
            Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.2),
                  Colors.amber.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.3),
                        Colors.amber.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.amber[700],
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Real-time Analysis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Powered by advanced sensor monitoring',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (lastUpdated != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Updated ${lastUpdated?.hour}:${lastUpdated?.minute.toString().padLeft(2, '0')}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.amber[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Loading State
          if (isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Analyzing greenhouse data...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI is generating personalized recommendations',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Error State
          if (!isLoading && errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red[700],
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Unable to Load',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchRecommendations,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // No Recommendations
          if (!isLoading && errorMessage.isEmpty && 
              (_recommendations == null || _recommendations!.recommendations.isEmpty))
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green[700],
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'All Systems Optimal',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your greenhouse conditions are perfect!\nAll parameters are within optimal ranges.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 18,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No action required',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
    ),
    );
  }
  
  Widget _buildRecommendationCard(AIRecommendation recommendation) {
    final theme = Theme.of(context);
    
    // Define colors based on recommendation type
    Color accentColor;
    Color gradientStart;
    Color gradientEnd;
    IconData iconData;
    
    switch (recommendation.type.toLowerCase()) {
      case 'temperature':
        accentColor = Colors.orange[700]!;
        gradientStart = Colors.orange.withOpacity(0.2);
        gradientEnd = Colors.orange.withOpacity(0.05);
        iconData = Icons.thermostat_rounded;
        break;
      case 'humidity':
        accentColor = Colors.blue[700]!;
        gradientStart = Colors.blue.withOpacity(0.2);
        gradientEnd = Colors.blue.withOpacity(0.05);
        iconData = Icons.water_drop_rounded;
        break;
      case 'co2':
        accentColor = Colors.green[700]!;
        gradientStart = Colors.green.withOpacity(0.2);
        gradientEnd = Colors.green.withOpacity(0.05);
        iconData = Icons.co2_rounded;
        break;
      case 'soil moisture':
      case 'soil':
        accentColor = Colors.brown[700]!;
        gradientStart = Colors.brown.withOpacity(0.2);
        gradientEnd = Colors.brown.withOpacity(0.05);
        iconData = Icons.water_outlined;
        break;
      case 'light':
        accentColor = Colors.amber[700]!;
        gradientStart = Colors.amber.withOpacity(0.2);
        gradientEnd = Colors.amber.withOpacity(0.05);
        iconData = Icons.wb_sunny_rounded;
        break;
      default:
        accentColor = Colors.grey[700]!;
        gradientStart = Colors.grey.withOpacity(0.2);
        gradientEnd = Colors.grey.withOpacity(0.05);
        iconData = Icons.eco_rounded;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and type
              Row(
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.3),
                          accentColor.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      iconData,
                      color: accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Type badge
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        recommendation.type.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Divider
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withOpacity(0.3),
                      accentColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tips_and_updates_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}