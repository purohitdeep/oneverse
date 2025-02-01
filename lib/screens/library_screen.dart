import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_verse/models/audio_book.dart';
import 'package:one_verse/models/generic_book.dart';
import 'package:one_verse/screens/book_info_screen.dart';
import 'package:one_verse/state_provider/app_state_notifier.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final selectedFolder = appState.library.selectedFolder;
    final books = appState.library.books;

return Scaffold(
  body: SafeArea(
    child: selectedFolder == null
        // If no folder is selected, show a message.
        ? const Center(
            child: Text('No folder selected. Please go to Settings to set a root folder.'),
          )
        : (books.isEmpty
            // If folder is set but no books are found, inform the user.
            ? const Center(child: Text('No books found in the selected folder.'))
            : ListView.builder(
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  final GenericBook book = books[index];
                  return ListTile(
                    leading: book.coverImage != null
                        ? Image.memory(
                            book.coverImage!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
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
                          builder: (BuildContext context) =>
                              BookInfoScreen(genericBook: book),
                        ),
                      );
                    },
                  );
                },
              )),
  ),
);
  }
}