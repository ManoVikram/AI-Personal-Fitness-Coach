import 'package:flutter/material.dart';

class ExerciseDetail extends StatelessWidget {
  final IconData icon;
  final String text;

  const ExerciseDetail({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(text, style: TextStyle(fontSize: 14.0, color: Colors.grey[700])),
      ],
    );
  }
}
