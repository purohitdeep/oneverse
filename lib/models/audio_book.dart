import 'package:one_verse/models/generic_book.dart';

class AudioBook extends GenericBook {
  final String duration;
  final String? albumName;
  final int? trackNumber;

  AudioBook({
    required super.id,
    required super.title,
    required super.author,
    super.filePath,
    super.coverImage,
    required this.duration,
    this.albumName,
    this.trackNumber,
  });
}
