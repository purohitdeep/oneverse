import 'dart:typed_data';

abstract class GenericBook {
  final String id;
  final String title;
  final String author;
  final String? filePath;
  final Uint8List? coverImage;

  GenericBook({
    required this.id,
    required this.title,
    required this.author,
    this.filePath,
    this.coverImage,
  });
}