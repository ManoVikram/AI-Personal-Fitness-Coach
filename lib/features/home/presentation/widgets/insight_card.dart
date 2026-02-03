import 'package:flutter/material.dart';

import '../../domain/models/insight.dart';

class InsightCard extends StatelessWidget {
  final Insight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;

    switch (insight.color) {
      case InsightColor.positive:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green.withValues(alpha: 0.3);
        iconColor = Colors.green;
        break;
      case InsightColor.warning:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        borderColor = Colors.orange.withValues(alpha: 0.3);
        iconColor = Colors.orange;
        break;
      case InsightColor.neutral:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue.withValues(alpha: 0.3);
        iconColor = Colors.blue;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.category.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  insight.observation,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
