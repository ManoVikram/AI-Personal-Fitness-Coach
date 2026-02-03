import 'package:flutter/material.dart';

import '../../domain/models/progress_insights.dart';
import 'insight_card.dart';
import 'summary_card.dart';

class InsightView extends StatelessWidget {
  final ProgressInsights insights;

  const InsightView({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          SummaryCard(summary: insights.summary),
          const SizedBox(height: 24.0),

          if (insights.insights.isNotEmpty) ...[
            const Text(
              'Key Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...insights.insights.map(
              (insight) => InsightCard(insight: insight),
            ),
          ],

          if (insights.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8.0),
            const Text(
              "Recommendations",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
          ],
        ],
      ),
    );
  }
}
