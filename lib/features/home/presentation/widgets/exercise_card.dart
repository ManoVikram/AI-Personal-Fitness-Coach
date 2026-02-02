import 'package:flutter/material.dart';

import '../../domain/models/exercise.dart';
import 'exercise_detail.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final int number;

  const ExerciseCard({super.key, required this.exercise, required this.number});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 32.0,
                  width: 32.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "$number",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                ExerciseDetail(
                  icon: Icons.repeat,
                  text: "${exercise.sets} sets",
                ),
                const SizedBox(width: 16.0),
                ExerciseDetail(
                  icon: Icons.fitness_center,
                  text: "${exercise.reps} reps",
                ),
                const SizedBox(width: 16.0),
                ExerciseDetail(
                  icon: Icons.timer,
                  text: "${exercise.restSeconds}s rest",
                ),
              ],
            ),

            if (exercise.notes.isNotEmpty) ...[
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, size: 16.0, color: Colors.amber),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        exercise.notes,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
