import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';
import 'package:one_verse/models/audio_book.dart';
import 'package:one_verse/models/generic_book.dart';
import 'package:one_verse/screens/book_info_screen.dart';
import 'package:one_verse/services/model_creator_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final Logger _logger = Logger('LibraryScreen');
  final ModelCreatorService _modelCreatorService = ModelCreatorService();
  List<GenericBook> audiobooks = <GenericBook>[];

  Future<void> _loadAudiobooks() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      Directory directory = Directory(directoryPath);
      List<FileSystemEntity> files = directory.listSync();

      _logger.info('📂 Selected directory: $directoryPath');
      _logger.info('📄 All files in directory: ${files.length} items');

      List<GenericBook> loadedBooks = <GenericBook>[];

      for (FileSystemEntity file in files) {
        try {
          GenericBook book = await _modelCreatorService
              .createGenericBookModelFromFile(File(file.path));
          loadedBooks.add(book);
        } catch (e) {
          _logger.severe('Error loading book from ${file.path}: $e');
        }
      }

      setState(() {
        audiobooks = loadedBooks;
      });

      _logger.fine('🎵 Filtered books: ${audiobooks.length} loaded');
    } else {
      _logger.warning('❌ No directory selected.');
    }
  }

  @override
  void initState() {
    super.initState();
    // Optionally, you can call _loadAudiobooks() here or trigger via the button.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: audiobooks.isEmpty
          ? const Center(
              child: Text('No books found. Please select a folder which has all your books.'))
          : ListView.builder(
              itemCount: audiobooks.length,
              itemBuilder: (BuildContext context, int index) {
                final GenericBook book = audiobooks[index];

                return ListTile(
                  leading: book.coverImage != null
                      ? Image.memory(
                          book.coverImage!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.audio_file,
                          size: 50),

                  title: Text(book.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(book.author),
                      if (book is AudioBook)
                        Text(
                          book.duration,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _loadAudiobooks();
          } catch (e) {
            _logger.severe('Error picking directory: $e');
          }
        },
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}
