import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_verse/screens/library_screen.dart';
import 'package:one_verse/screens/player_screen.dart';
import 'package:one_verse/screens/search_screen.dart';
import 'package:one_verse/screens/settings_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  // StateProvider to store the selected screen
  final selectedScreenProvider =
      StateProvider<Widget>((ref) => const LibraryScreen());

  @override
  Widget build(BuildContext context) {
    final selectedScreen = ref.watch(selectedScreenProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // Smaller AppBar height
        child: AppBar(
          title: const SizedBox.shrink(),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'OneVerse',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.library_books,
              text: 'Library',
              screen: const LibraryScreen(),
              selectedScreen: selectedScreen,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.play_circle,
              text: 'Player',
              screen: const PlayerScreen(),
              selectedScreen: selectedScreen,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.search,
              text: 'Search',
              screen: const SearchScreen(),
              selectedScreen: selectedScreen,
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              text: 'Settings',
              screen: const SettingsScreen(),
              selectedScreen: selectedScreen,
            ),
          ],
        ),
      ),
      body: selectedScreen, // Display the selected screen
    );
  }

  // Helper function to create a selectable drawer item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Widget screen,
    required Widget selectedScreen,
  }) {
    final bool isSelected = screen.runtimeType == selectedScreen.runtimeType;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        ),
      ),
      selected: isSelected, // Highlights the selected option
      selectedTileColor: Colors.blue.shade100, // Light blue background
      onTap: () {
        ref.read(selectedScreenProvider.notifier).state = screen;
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}