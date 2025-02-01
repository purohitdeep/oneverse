import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:one_verse/screens/library_screen.dart';
import 'package:one_verse/screens/player_screen.dart';
import 'package:one_verse/screens/search_screen.dart';
import 'package:one_verse/screens/settings_screen.dart';
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
      title: 'OneVerse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(), // Start with the Library screen
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends ConsumerState<MainScreen> {
final selectedScreenProvider = StateProvider<Widget>((ref) => const LibraryScreen());
  @override
  Widget build(BuildContext context) {
    final selectedScreen = ref.watch(selectedScreenProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('OneVerse')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('OneVerse', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Library'),
              onTap: () => ref.read(selectedScreenProvider.notifier).state = const LibraryScreen(),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Player'),
              onTap: () => ref.read(selectedScreenProvider.notifier).state = const PlayerScreen(),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () => ref.read(selectedScreenProvider.notifier).state = const SearchScreen(),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => ref.read(selectedScreenProvider.notifier).state = const SettingsScreen(),
            ),
          ],
        ),
      ),
      body: selectedScreen,
    );
  }
}
