import 'dart:io';

import 'package:flutter/material.dart';
import 'package:one_verse/screens/book_info.dart';
import 'package:file_picker/file_picker.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Map<String, dynamic>> audiobooks = [];

  Future<void> _loadAudiobooks() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'ogg', 'wav', 'flac'],
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> files = result.files;

      setState(() {
        audiobooks = files.map((file) {
          String title = file.name;
          String author = 'Author Placeholder';
          String coverImage = 'assets/placeholder.jpg';

          return {
            'title': title,
            'author': author,
            'coverImage': coverImage,
            'extension': file.extension,
          };
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
//    _loadAudiobooks(); // Load audiobooks when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobook Library'),
      ),
      body: audiobooks.isEmpty
          ? const Center(
              child: Text('No audiobooks found. Please select a folder.'))
          : ListView.builder(
              itemCount: audiobooks.length,
              itemBuilder: (context, index) {
                final audiobook = audiobooks[index];
                return ListTile(
                  leading: Image.asset(audiobook['coverImage']),
                  title: Text(audiobook['title']),
                  subtitle: Text(audiobook['author']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BookInfoScreen(audiobook: audiobook),
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
            print(
                'Error picking directory: $e'); // Or display an error message to the user
          }
        },
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}
