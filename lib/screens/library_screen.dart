import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_verse/models/audio_book.dart';
import 'package:one_verse/models/generic_book.dart';
import 'package:one_verse/screens/book_info_screen.dart';
import 'package:one_verse/state_provider/app_state_notifier.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  Future<void> _pickFolder(WidgetRef ref) async {
    String? folderPath = await FilePicker.platform.getDirectoryPath();
    if (folderPath != null) {
      ref.read(appStateProvider.notifier).setLibraryFolder(folderPath);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final selectedFolder = appState.library.selectedFolder;
    final books = appState.library.books;

    return Scaffold(
      appBar: AppBar(
        title: Text('Library ${selectedFolder != null ? '($selectedFolder)' : ''}'),
      ),
      body: books.isEmpty
          ? const Center(child: Text('No books found. Please select a root folder, where you have all your books.'))
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (BuildContext context, int index) {
                
                final GenericBook book = books[index];

                return ListTile(
                  leading: book.coverImage != null
                      ? Image.memory(book.coverImage!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.audio_file, size: 50),

                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(book.author),
                      if (book is AudioBook)
                        Text(
                          book.duration,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => BookInfoScreen(genericBook: book),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickFolder(ref),
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}