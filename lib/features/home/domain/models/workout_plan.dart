import 'exercise.dart';

class WorkoutPlan {
  final String day;
  final String focus;
  final List<Exercise> exercises;
  final int totalDurationMins;
  final String difficulty;

  const WorkoutPlan({
    required this.day,
    required this.focus,
    required this.exercises,
    required this.totalDurationMins,
    required this.difficulty,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      day: json["day"] ?? "",
      focus: json["focus"] ?? "",
      exercises:
          (json["exercises"] as List?)
              ?.map(
                (exercise) =>
                    Exercise.fromJson(exercise as Map<String, dynamic>),
              )
              .toList() ??
          [],
      totalDurationMins: json["totalDurationMins"],
      difficulty: json["difficulty"],
    );
  }
}
