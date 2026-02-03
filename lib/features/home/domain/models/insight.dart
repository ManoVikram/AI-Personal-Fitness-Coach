class Insight {
  final String category;
  final String observation;
  final String impact;

  Insight({
    required this.category,
    required this.observation,
    required this.impact,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      category: json["category"] ?? "",
      observation: json["observation"] ?? "",
      impact: json["impact"] ?? "",
    );
  }

  String get emoji {
    switch (impact.toLowerCase()) {
      case "positive":
        return "✅";
      case "needs_attention":
        return "⚠️";
      default:
        return "👍";
    }
  }

  InsightColor get color {
    switch (impact.toLowerCase()) {
      case "positive":
        return InsightColor.positive;
      case "needs_attention":
        return InsightColor.warning;
      default:
        return InsightColor.neutral;
    }
  }
}

enum InsightColor { positive, warning, neutral }
