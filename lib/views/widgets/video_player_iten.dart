// lib/views/widgets/video_player_item.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart'; // Agar GetX use kar rahe hain snackbars ke liye

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        videoPlayerController.play();
        videoPlayerController.setVolume(1.0);
        videoPlayerController.setLooping(true); // Looping enable karna
      }).catchError((error) {
        debugPrint('Error initializing video player: $error');
        Get.snackbar('Error', 'Failed to load video'); // Agar GetX use kar rahe hain
      });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
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
      child: _isInitialized
          ? AspectRatio(
        aspectRatio: videoPlayerController.value.aspectRatio,
        child: VideoPlayer(videoPlayerController),
      )
          : const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
