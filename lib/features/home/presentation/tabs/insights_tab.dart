import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_repository.dart';
import '../../domain/models/progress_insights.dart';
import '../../providers/api_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/insight_view.dart';
import '../widgets/no_data_stat.dart';

class InsightsTab extends ConsumerWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ApiRepository? apiRepository = ref.watch(apiRepositoryProvider);

    if (apiRepository == null) {
      return Center(child: Text("Not authenticated"));
    }

    return FutureBuilder(
      future: apiRepository.getInsights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.0),
                Text("Analyzing your progress..."),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return ErrorState(error: snapshot.data!["message"]);
        }

        if (!snapshot.hasData) {
          return EmptyState();
        }

        if (snapshot.data!.containsKey("message")) {
          return NoDataState(message: snapshot.data!["message"]);
        }

        final ProgressInsights insights = ProgressInsights.fromJson(
          snapshot.data!,
        );
        return InsightView(insights: insights);
      },
    );
  }
}
