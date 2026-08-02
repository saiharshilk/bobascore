import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/boba_score_screen.dart';
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: BobaScoreApp()));
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
