// lib/views/widgets/video_thumbnail.dart

import 'package:flutter/material.dart';

class VideoThumbnail extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnail({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Thumbnail Image
        Positioned.fill(
          child: Image.network(
            videoUrl,
            fit: BoxFit.cover,
          ),
        ),
        // Play Icon Overlay
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white.withOpacity(0.7),
              size: 50,
            ),
          ),
        ),
      ],
    );
  }
}
