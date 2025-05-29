import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCustomize extends StatefulWidget {
  const VideoPlayerCustomize({super.key});

  @override
  State<VideoPlayerCustomize> createState() => _VideoPlayerCustomizeState();
}

class _VideoPlayerCustomizeState extends State<VideoPlayerCustomize> {
  final List<Map<String, String>> videos = [
    {
      'title': 'Big Buck Bunny',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'thumbnail':
          'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217',
    },
    {
      'title': 'Elephant Dream',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'thumbnail':
          'https://orange.blender.org/wp-content/themes/orange/images/media/gallery/ed_hd_070.jpg',
    },
    {
      'title': 'Sintel',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      'thumbnail':
          'https://durian.blender.org/wp-content/uploads/2010/05/sintel_poster.jpg',
    },
    {
      'title': 'Tears of Steel',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      'thumbnail':
          'https://mango.blender.org/wp-content/uploads/2013/05/03_thom_celia_bridge.jpg',
    },
    {
      'title': 'For Bigger Escapes',
      'url':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    },
  ];

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  int currentIndex = 0;
  bool autoPlay = false;

  List<Duration?> videoDurations = [];

  Future<void> _loadAllDurations() async {
    for (var video in videos) {
      final controller = VideoPlayerController.network(video['url']!);
      await controller.initialize();
      videoDurations.add(controller.value.duration);
      await controller.dispose();
    }
  }

  Future<void> _initializePlayer(int index) async {
    setState(() {
      autoPlay = true;
    });
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = VideoPlayerController.network(
      videos[index]["url"]!,
    );
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: autoPlay,
      looping: false,
    );
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllDurations().then((_) {
      setState(() {});
    });
    _initializePlayer(currentIndex);
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first.padLeft(8, "0");
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = videos[currentIndex];
    return Scaffold(
      appBar: AppBar(title: const Text("Video List")),
      body: Column(
        children: [
          _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AspectRatio(
                  aspectRatio:
                      _chewieController!
                          .videoPlayerController
                          .value
                          .aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
              )
              : const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final duration =
                    videoDurations.length > index
                        ? videoDurations[index]
                        : null;
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    trailing:
                        duration != null
                            ? Text("Duration: ${formatDuration(duration)}")
                            : const SizedBox(
                              width: 60,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    title: Text(video['title']!),
                    onTap: () => _initializePlayer(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
