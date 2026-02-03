import 'package:flutter/material.dart';

class NoDataState extends StatelessWidget {
  final String message;

  const NoDataState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 80.0, color: Colors.grey[400]),
            const SizedBox(height: 24.0),
            Text(
              "No Workout Data Yet",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "ABC",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "ABC",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32.0),
            const Text(
              "Start loggin workouts to see\nyour progress insights!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
