import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:one_verse/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  _setupLogging();
  runApp(
    ProviderScope(
      child: const OneVerse(),
    ),
  );
}

void _setupLogging() {
  // Set the root level for logging. Level.ALL logs everything.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    // Use dart:developer for production-friendly logging
    debugPrint(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });
}

class OneVerse extends StatelessWidget {
  const OneVerse({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // Start with the Library screen
    );
  }
}


