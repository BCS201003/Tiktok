import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState(); // Corrected
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure setState is called only after initialization
        setState(() {
          videoPlayerController.play();
          videoPlayerController.setVolume(1.0); // Ensure volume is set explicitly
        });
      }).catchError((error) {
        // Handle potential errors during initialization
        debugPrint('Error initializing video player: $error');
      });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose(); // Corrected disposal order
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: videoPlayerController.value.isInitialized
          ? AspectRatio(
        aspectRatio: videoPlayerController.value.aspectRatio,
        child: VideoPlayer(videoPlayerController),
      )
          : const Center(
        child: CircularProgressIndicator(
          color: Colors.white, // Loading indicator for initialization
        ),
      ),
    );
  }
}
