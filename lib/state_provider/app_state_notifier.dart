import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_verse/state_provider/app_state.dart';
import 'package:one_verse/state_provider/audio_player_state.dart';
import 'package:one_verse/state_provider/book_progress_state.dart';
import 'package:one_verse/state_provider/library_state.dart';
import 'package:one_verse/models/generic_book.dart';
import 'package:one_verse/services/model_creator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateNotifier extends StateNotifier<AppState> {
  final ModelCreatorService _modelCreatorService = ModelCreatorService();

  AppStateNotifier()
      : super(AppState(
          library: LibraryState(),
          audioPlayer: AudioPlayerState(),
          ebook: BookProgressState(),
        )) {
    _loadSavedFolder();
  }

  // 📌 Load selected folder from SharedPreferences when app starts
  Future<void> _loadSavedFolder() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? savedFolder = sharedPreferences.getString('selected_library_folder');
    if (savedFolder != null) {
      state = state.copyWith(library: state.library.copyWith(selectedFolder: savedFolder));
      await loadBooksFromFolder(savedFolder);
    }
  }

  // 📌 Update selected folder & load books
  Future<void> setLibraryFolder(String folderPath) async {
    state = state.copyWith(library: state.library.copyWith(selectedFolder: folderPath));
    
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('selected_library_folder', folderPath);

    await loadBooksFromFolder(folderPath);
  }

  // 📌 Load Books from the Folder
  Future<void> loadBooksFromFolder(String folderPath) async {
    Directory directory = Directory(folderPath);
    if (!directory.existsSync()) return;

    List<FileSystemEntity> files = directory.listSync();
    List<GenericBook> loadedBooks = [];

    for (var file in files) {
      try {
        GenericBook book = await _modelCreatorService.createGenericBookModelFromFile(File(file.path));
        loadedBooks.add(book);
      } catch (e) {
        print('Error loading book from ${file.path}: $e');
      }
    }

    state = state.copyWith(library: state.library.copyWith(books: loadedBooks));
  }

  // 📌 Audiobook Controls
  void playAudio(String trackPath) {
    state = state.copyWith(audioPlayer: state.audioPlayer.copyWith(currentTrack: trackPath, isPlaying: true));
  }

  void pauseAudio() {
    state = state.copyWith(audioPlayer: state.audioPlayer.copyWith(isPlaying: false));
  }

  void seekAudio(Duration position) {
    state = state.copyWith(audioPlayer: state.audioPlayer.copyWith(position: position));
  }

  void stopAudio() {
    state = state.copyWith(audioPlayer: AudioPlayerState());
  }

  // 📌 Ebook Controls
  void setBookProgress(String bookId, int page) {
    state = state.copyWith(ebook: state.ebook.copyWith(currentBookId: bookId, currentPage: page));
  }

  void nextPage() {
    state = state.copyWith(ebook: state.ebook.copyWith(currentPage: state.ebook.currentPage + 1));
  }

  void previousPage() {
    state = state.copyWith(ebook: state.ebook.copyWith(currentPage: state.ebook.currentPage > 0 ? state.ebook.currentPage - 1 : 0));
  }
}

// ✅ Global Provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);