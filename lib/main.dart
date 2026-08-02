import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/hive_service_provider.dart';
import 'screens/boba_score_screen.dart';
import 'services/hive_service.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = await HiveService.initialize();

  runApp(
    ProviderScope(
      overrides: [hiveServiceProvider.overrideWithValue(hiveService)],
      child: const BobaScoreApp(),
    ),
  );
}

class BobaScoreApp extends StatelessWidget {
  const BobaScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BobaScore',
      theme: bobaTheme,
      home: const BobaScoreScreen(),
    );
  }
}
