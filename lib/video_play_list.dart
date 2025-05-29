import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPlaylistScreen extends StatefulWidget {
  @override
  _VideoPlaylistScreenState createState() => _VideoPlaylistScreenState();
}

class _VideoPlaylistScreenState extends State<VideoPlaylistScreen> {
  final List<String> videoUrls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  ];

  int currentIndex = 0;
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrls[currentIndex]),
    );

    await _videoPlayerController.initialize();

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position >=
              _videoPlayerController.value.duration &&
          !_videoPlayerController.value.isPlaying) {
        _playNextVideo();
      }
    });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
    );

    setState(() {});
  }

  void _playNextVideo() async {
    if (currentIndex < videoUrls.length - 1) {
      currentIndex++;
      await _chewieController?.pause();
      _chewieController?.dispose();
      await _videoPlayerController.dispose();
      await _initializePlayer();
    }
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady =
        _chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized;

    return Scaffold(
      appBar: AppBar(title: Text('Video Playlist')),
      body:
          isReady
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio:
                        _chewieController!
                            .videoPlayerController
                            .value
                            .aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: _videoPlayerController,
                    builder: (context, VideoPlayerValue value, child) {
                      final position = value.position;
                      final duration = value.duration;
                      final remaining = duration - position;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Position: ${formatDuration(position)}"),
                            Text("Remaining: ${formatDuration(remaining)}"),
                            Text("Duration: ${formatDuration(duration)}"),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
              : Center(child: CircularProgressIndicator()),
    );
  }
}
