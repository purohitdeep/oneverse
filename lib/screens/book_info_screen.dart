
import 'package:flutter/material.dart';
import 'package:one_verse/models/audio_book.dart';
import 'package:one_verse/models/generic_book.dart';
import 'package:one_verse/screens/audio_player_screen.dart';

class BookInfoScreen extends StatelessWidget {
  final GenericBook genericBook;

  const BookInfoScreen({super.key, required this.genericBook});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(genericBook.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (genericBook.coverImage != null)
              Image.memory(
                genericBook.coverImage!,
                width: 150,
                height: 150,
                fit: BoxFit.fill,
              )
            else
              Container(
                width: 150,
                height: 150,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.music_note,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Author: ${genericBook.author}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            if (genericBook is AudioBook)
              Text(
                'Duration: ${(genericBook as AudioBook).duration}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 20),

            // Play Button (Only for AudioBook)
            // Example persistent player instance; replace with your actual instance

            if (genericBook is AudioBook)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPlayerScreen(
                          audioBook: genericBook as AudioBook,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Play"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
