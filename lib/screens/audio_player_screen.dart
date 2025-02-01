import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:one_verse/models/audio_book.dart';

class AudioPlayerScreen extends StatefulWidget {
  final AudioBook audioBook;

  const AudioPlayerScreen({super.key, required this.audioBook});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setReleaseMode(ReleaseMode.stop);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Set up your audio source and start playing
      await _player.setSource(DeviceFileSource(widget.audioBook.filePath!));
      await _player.resume();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the body in a container so you can set a background color or gradient
    return Scaffold(
      appBar: AppBar(title: Text(widget.audioBook.title)),
      body: Container(
        width: double.infinity,
        // Example: a simple background color (adjust or replace with gradient)
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // ALBUM ART
              _buildAlbumArt(),
              const SizedBox(height: 20),
              // TITLE (e.g., Chapter title)
              Text(
                widget.audioBook.title, // or use widget.audioBook.title if you prefer
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // MAIN CONTROLS & PROGRESS
              Expanded(
                child: Center(
                  child: PlayerWidget(player: _player),
                ),
              ),

              // OPTIONAL EXTRA ROW FOR SPEED / CAR MODE / TIMER / BOOKMARK
              // Uncomment if you want more controls
              _buildExtraControls(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    final coverImage = widget.audioBook.coverImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0), // Rounded corners
      child: coverImage != null
          ? Image.memory(
              coverImage,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            )
          : Container(
              width: 300,
              height: 300,
              color: Colors.grey,
              child: const Icon(Icons.audiotrack, size: 80),
            ),
    );
  }

  // Optional extra row at bottom
  Widget _buildExtraControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text("1.0x", style: TextStyle(color: Colors.white)),
          //Icon(Icons.directions_car, color: Colors.white),
          Icon(Icons.timer, color: Colors.white),
          Icon(Icons.bookmark_border, color: Colors.white),
        ],
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  const PlayerWidget({Key? key, required this.player}) : super(key: key);

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  String get _durationText =>
      _duration != null ? _printDuration(_duration!) : "0:00";
  String get _positionText =>
      _position != null ? _printDuration(_position!) : "0:00";

  /// Simple helper to show "mm:ss" or "hh:mm:ss" format
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  /// If you want “time left” in the middle, this calculates it
  String get _timeLeftText {
    if (_duration == null || _position == null) return "";
    final diff = _duration! - _position!;
    return "${diff.inMinutes}m ${diff.inSeconds.remainder(60)}s left";
  }

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    _playerState = player.state;
    player.getDuration().then((value) {
      setState(() {
        _duration = value;
      });
    });
    player.getCurrentPosition().then((value) {
      setState(() {
        _position = value;
      });
    });
    _initStreams();
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    _positionSubscription = player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });
    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() => _playerState = state);
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _play() async {
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _skipBack30() async {
    final currentPosition = _position ?? Duration.zero;
    // Rewind 30 seconds, but not below 0
    Duration newPosition = currentPosition - const Duration(seconds: 30);
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    await player.seek(newPosition);
  }

  Future<void> _skipForward30() async {
    final currentPosition = _position ?? Duration.zero;
    // Fast-forward 30 seconds, but not beyond total duration
    Duration newPosition = currentPosition + const Duration(seconds: 30);
    if (_duration != null && newPosition > _duration!) {
      newPosition = _duration!;
    }
    await player.seek(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Space things out a bit
      mainAxisSize: MainAxisSize.min,
      children: [
        // PROGRESS BAR DETAILS: current time, time left, total time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _positionText,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _timeLeftText,
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _durationText,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        // SLIDER
        Slider(
          activeColor: Colors.white,
          inactiveColor: Colors.white54,
          onChanged: (value) {
            if (_duration == null) return;
            final position = value * _duration!.inMilliseconds;
            player.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
        ),

        // BUTTONS: skip-back-30, play/pause, skip-forward-30
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _skipBack30,
              icon: const Icon(Icons.replay_30),
              iconSize: 40,
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: _isPlaying ? _pause : _play,
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              iconSize: 60,
              color: Colors.white,
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: _skipForward30,
              icon: const Icon(Icons.forward_30),
              iconSize: 40,
              color: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}