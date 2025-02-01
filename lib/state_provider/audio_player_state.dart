
class AudioPlayerState {
  final String? currentTrack;
  final Duration position;
  final bool isPlaying;

  AudioPlayerState({
    this.currentTrack,
    this.position = Duration.zero,
    this.isPlaying = false,
  });

  AudioPlayerState copyWith({
    String? currentTrack,
    Duration? position,
    bool? isPlaying,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}