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
      // Assuming your AudioBook has an 'assetPath' property.
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.audioBook.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display album art if available!
          widget.audioBook.coverImage != null
              ? Image.memory(
                  widget.audioBook.coverImage!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                )
              : Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey,
                  child: const Icon(Icons.audiotrack, size: 80),
                ),
          const SizedBox(height: 20),
          // Here comes the fancy player controls widget!
          PlayerWidget(player: _player),
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
  bool get _isPaused => _playerState == PlayerState.paused;

  String get _durationText =>
      _duration != null ? _duration.toString().split('.').first : '0:00';
  String get _positionText =>
      _position != null ? _position.toString().split('.').first : '0:00';

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

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play, Pause, and Stop buttons—like the control panel of a spaceship!
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              key: const Key('play_button'),
              onPressed: _isPlaying ? null : _play,
              iconSize: 48.0,
              icon: const Icon(Icons.play_arrow),
              color: color,
            ),
            IconButton(
              key: const Key('pause_button'),
              onPressed: _isPlaying ? _pause : null,
              iconSize: 48.0,
              icon: const Icon(Icons.pause),
              color: color,
            ),
            IconButton(
              key: const Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? _stop : null,
              iconSize: 48.0,
              icon: const Icon(Icons.stop),
              color: color,
            ),
          ],
        ),
        // A slider to show the audio progress (slide to your heart's content!)
        Slider(
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
        // Display current time versus total duration
        Text(
          '$_positionText / $_durationText',
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }
}