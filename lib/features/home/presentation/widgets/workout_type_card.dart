import 'package:flutter/material.dart';

class WorkoutTypeCard extends StatelessWidget {
  final bool _isGenerating;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const WorkoutTypeCard({
    super.key,
    required bool isGenerating,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : _isGenerating = isGenerating;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isGenerating ? null : onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: color, size: 32.0),
            ),
            SizedBox(height: 4.0),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20.0),
          ],
        ),
      ),
    );
  }
}
