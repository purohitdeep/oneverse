import 'package:flutter/material.dart';
import 'package:one_verse/screens/library_screen.dart';
import 'package:one_verse/screens/player_screen.dart';
import 'package:one_verse/screens/search_screen.dart';
import 'package:one_verse/screens/settings_screen.dart';

void main() {
  runApp(const OneVerse());
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _currentScreen = const LibraryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneVerse App'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'OneVerse App Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Library'),
              onTap: () {
                setState(() {
                  _currentScreen = const LibraryScreen();
                });
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('Player'),
              onTap: () {
                setState(() {
                  _currentScreen = const PlayerScreen();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search'),
              onTap: () {
                setState(() {
                  _currentScreen = const SearchScreen();
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                setState(() {
                  _currentScreen = const SettingsScreen();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}