import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_repository.dart';
import '../../domain/models/workout_plan.dart';
import '../../providers/api_provider.dart';
import '../widgets/workout_selector.dart';

class WorkoutTab extends ConsumerStatefulWidget {
  const WorkoutTab({super.key});

  @override
  ConsumerState<WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends ConsumerState<WorkoutTab> {
  WorkoutPlan? _currentWorkout;
  bool _isGenerating = false;

  Future<void> _generateWorkout(String workoutType) async {
    final ApiRepository? apiRepository = ref.watch(apiRepositoryProvider);

    if (apiRepository == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Not authenticated")));
      return;
    }

    try {
      final Map<String, dynamic> response = await apiRepository.generateWorkout(
        workoutType,
      );
      final WorkoutPlan workout = WorkoutPlan.fromJson(response);

      setState(() {
        _currentWorkout = workout;
        _isGenerating = false;
      });
    } catch (error) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WorkoutSelector(
      isGenerating: _isGenerating,
      generateWorkout: _generateWorkout,
    );
  }
}
