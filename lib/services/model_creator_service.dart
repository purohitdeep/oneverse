import 'dart:io';
import 'dart:typed_data';

import 'package:one_verse/models/audio_book.dart';
import 'package:one_verse/models/generic_book.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:logging/logging.dart';

class ModelCreatorService {
  final Logger _logger = Logger('ModelCreatorService');

  Future<GenericBook> createGenericBookModelFromFile(File file) async {
    GenericBook? genericBook;
    String extension = file.path.split('.').last.toLowerCase();
    if (<String>['mp3', 'm4a', 'ogg', 'wav', 'flac'].contains(extension)) {
      genericBook = await createAudioBookModelFromFile(file);
    } else {
      return genericBook!;
    }
    return genericBook;
  }

  Future<AudioBook> createAudioBookModelFromFile(File file) async {
    AudioBook audiobook;
    try {
      final Metadata metadata =
          await MetadataRetriever.fromFile(File(file.path));

      String title =
          metadata.albumName ?? _removeFileExtension(file.path.split('/').last);
      String author = metadata.albumArtistName ?? 'Unknown Artist';
      String filePath = file.path;
      Uint8List? coverImage = metadata.albumArt;
      String duration = metadata.trackDuration != null
          ? _formatDuration(Duration(milliseconds: metadata.trackDuration!))
          : '?';
      String? albumName = metadata.albumName;
      int? trackNumber = metadata.trackNumber;

      audiobook = AudioBook(
          id: file.path,
          title: title,
          author: author,
          filePath: filePath,
          coverImage: coverImage,
          duration: duration,
          albumName: albumName,
          trackNumber: trackNumber);
    } catch (e) {
      _logger.severe('Error reading metadata for ${file.path}: $e');
      // Fallback in case metadata extraction fails
      audiobook = AudioBook(
        id: file.path,
        title: file.path.split('/').last,
        author: 'Unknown Artist',
        filePath: file.path,
        coverImage: null,
        duration: '?',
      );
    }
    return audiobook;
  }

  String _removeFileExtension(String fileName) {
    return fileName.replaceAll(RegExp(r'\.\w+$'), '');
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '?';
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }
}
