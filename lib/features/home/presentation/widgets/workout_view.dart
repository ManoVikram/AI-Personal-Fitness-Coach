import 'package:flutter/material.dart';

import '../../domain/models/workout_plan.dart';
import 'exercise_card.dart';
import 'info_chip.dart';

class WorkoutView extends StatelessWidget {
  final WorkoutPlan currentWorkout;
  final VoidCallback onBack;

  const WorkoutView({
    super.key,
    required this.currentWorkout,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: onBack, icon: Icon(Icons.arrow_back)),
                    const SizedBox(width: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 56.0),
                      child: Row(
                        children: [
                          InfoChip(
                            icon: Icons.timer,
                            label: "${currentWorkout.totalDurationMins} mins",
                          ),
                          const SizedBox(width: 8.0),
                          InfoChip(
                            icon: Icons.trending_up,
                            label: currentWorkout.difficulty,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: currentWorkout.exercises.length,
            itemBuilder: (context, index) {
              return ExerciseCard(
                exercise: currentWorkout.exercises[index],
                number: index + 1,
              );
            },
          ),
        ),
      ],
    );
  }
}
