class AIRecommendation {
  final String title;
  final String description;
  final String type;

  AIRecommendation({
    required this.title,
    required this.description,
    required this.type,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'general',
    );
  }
}

class AIRecommendations {
  final List<AIRecommendation> recommendations;
  final DateTime timestamp;

  AIRecommendations({
    required this.recommendations,
    required this.timestamp,
  });

  factory AIRecommendations.fromJson(Map<String, dynamic> json) {
    final recommendationsList = json['recommendations'] as List? ?? [];
    return AIRecommendations(
      recommendations: recommendationsList
          .map((item) => AIRecommendation.fromJson(item))
          .toList(),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['timestamp'] * 1000).round())
          : DateTime.now(),
    );
  }
}