import 'insight.dart';

class ProgressInsights {
  final String summary;
  final List<Insight> insights;
  final List<String> recommendations;

  ProgressInsights({
    required this.summary,
    required this.insights,
    required this.recommendations,
  });

  factory ProgressInsights.fromJson(Map<String, dynamic> json) {
    return ProgressInsights(
      summary: json["summary"] ?? "",
      insights:
          (json["insights"] as List?)
              ?.map(
                (element) => Insight.fromJson(element as Map<String, dynamic>),
              )
              .toList() ??
          [],
      recommendations:
          (json["recommendations"] as List?)
              ?.map((element) => element.toString())
              .toList() ??
          [],
    );
  }
}
