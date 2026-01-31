class Exercise {
  final String name;
  final int sets;
  final String reps;
  final int restSeconds;
  final String notes;

  const Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json["name"] ?? "",
      sets: json["sets"] ?? 0,
      reps: json["reps"] ?? "",
      restSeconds: json["restSeconds"] ?? 0,
      notes: json["notes"] ?? "",
    );
  }
}
