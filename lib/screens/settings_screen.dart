import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_verse/state_provider/app_state_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _pickFolder(WidgetRef ref) async {
    final String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      ref.read(appStateProvider.notifier).setLibraryFolder(folderPath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final selectedFolder = appState.library.selectedFolder;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedFolder == null
                  ? 'No folder selected.'
                  : 'Selected folder: $selectedFolder',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickFolder(ref),
              child: const Text('Select Root Folder'),
            ),
          ],
        ),
      ),
    );
  }
}