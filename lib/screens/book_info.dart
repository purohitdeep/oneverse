import 'package:flutter/material.dart';

class BookInfoScreen extends StatelessWidget {
  final Map<String, dynamic> audiobook;

  const BookInfoScreen({super.key, required this.audiobook});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(audiobook['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(audiobook['coverImage']),
            const SizedBox(height: 16),
            Text(
              'Author: ${audiobook['author']}',
              style: const TextStyle(fontSize: 18),
            ),
            // Add more details here (summary, etc.)
          ],
        ),
      ),
    );
  }
}