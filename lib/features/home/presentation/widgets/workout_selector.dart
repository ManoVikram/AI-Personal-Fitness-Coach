import 'package:flutter/material.dart';

import 'workout_type_card.dart';

class WorkoutSelector extends StatelessWidget {
  final bool _isGenerating;
  final Function(String) generateWorkout;

  const WorkoutSelector({
    super.key,
    required bool isGenerating,
    required this.generateWorkout,
  }) : _isGenerating = isGenerating;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20.0),

          const Text(
            "What do you want to\ntrain today?",
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),

          WorkoutTypeCard(
            isGenerating: _isGenerating,
            title: "Upper Body",
            subtitle: "Chest, Back, Arms",
            icon: Icons.fitness_center,
            color: Colors.blue,
            onTap: () => generateWorkout("upper_body"),
          ),
          const SizedBox(height: 16.0),

          WorkoutTypeCard(
            isGenerating: _isGenerating,
            title: "Lower Body",
            subtitle: "Legs, Glutes, Calves",
            icon: Icons.directions_run,
            color: Colors.green,
            onTap: () => generateWorkout("lower_body"),
          ),
          const SizedBox(height: 16.0),

          WorkoutTypeCard(
            isGenerating: _isGenerating,
            title: "Full Body",
            subtitle: "Total body workout",
            icon: Icons.accessibility_new,
            color: Colors.orange,
            onTap: () => generateWorkout("full_body"),
          ),
          const SizedBox(height: 16.0),

          WorkoutTypeCard(
            isGenerating: _isGenerating,
            title: "Coare & Abs",
            subtitle: "Core strength",
            icon: Icons.favorite,
            color: Colors.red,
            onTap: () => generateWorkout("core"),
          ),
          const SizedBox(height: 16.0),

          if (_isGenerating) ...[
            const SizedBox(height: 32.0),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16.0),
                  Text(
                    "Generating your personalized\nworkout plan...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    "This may take 10-15 seconds",
                    style: TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
