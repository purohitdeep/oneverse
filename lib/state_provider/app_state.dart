import 'package:one_verse/state_provider/audio_player_state.dart';
import 'package:one_verse/state_provider/book_progress_state.dart';
import 'package:one_verse/state_provider/library_state.dart';

class AppState {
  final LibraryState library;
  final AudioPlayerState audioPlayer;
  final BookProgressState ebook;

  AppState({required this.library, required this.audioPlayer, required this.ebook});

  AppState copyWith({
    LibraryState? library,
    AudioPlayerState? audioPlayer,
    BookProgressState? ebook,
  }) {
    return AppState(
      library: library ?? this.library,
      audioPlayer: audioPlayer ?? this.audioPlayer,
      ebook: ebook ?? this.ebook,
    );
  }
}