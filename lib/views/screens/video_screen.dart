// lib/views/screens/video_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/video_controller.dart';
import 'package:tiktok_tutorial/controllers/auth_controller.dart';
import 'package:tiktok_tutorial/views/screens/comment_screen.dart';
import 'package:tiktok_tutorial/views/widgets/circle_animation.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/views/widgets/video_player_iten.dart';

class VideoScreen extends StatelessWidget {
  VideoScreen({Key? key}) : super(key: key);

  final VideoController videoController = Get.put(VideoController());
  final AuthController authController = Get.find<AuthController>();

  Widget buildProfile(String profilePhotoPath, double size) {
    return SizedBox(
      width: size * 0.15,
      height: size * 0.15,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.012,
            child: Container(
              width: size * 0.125,
              height: size * 0.125,
              padding: EdgeInsets.all(size * 0.002),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(size * 0.0625),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.0625),
                child: profilePhotoPath.startsWith('http')
                    ? Image.network(
                  profilePhotoPath,
                  fit: BoxFit.cover,
                )
                    : File(profilePhotoPath).existsSync()
                    ? Image.file(
                  File(profilePhotoPath),
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.error,
                  color: Colors.red,
                  size: size * 0.05,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMusicAlbum(String profilePhotoPath, double size) {
    return SizedBox(
      width: size * 0.15,
      height: size * 0.15,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(size * 0.03),
            height: size * 0.125,
            width: size * 0.125,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.white],
              ),
              borderRadius: BorderRadius.circular(size * 0.0625),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.0625),
              child: profilePhotoPath.startsWith('http')
                  ? Image.network(
                profilePhotoPath,
                fit: BoxFit.cover,
              )
                  : File(profilePhotoPath).existsSync()
                  ? Image.file(
                File(profilePhotoPath),
                fit: BoxFit.cover,
              )
                  : Icon(
                Icons.error,
                color: Colors.red,
                size: size * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Obx(() {
        return PageView.builder(
          itemCount: videoController.videoList.length,
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final data = videoController.videoList[index];
            return Stack(
              children: [
                // Video Player
                VideoPlayerItem(
                  videoUrl: data.videoUrl,
                ),
                // Video Details and Actions
                Column(
                  children: [
                    SizedBox(height: screenSize.height * 0.1),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: screenSize.width * 0.05),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    data.username,
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.05,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    data.caption,
                                    style: TextStyle(
                                      fontSize: screenSize.width * 0.04,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.music_note,
                                        size: screenSize.width * 0.04,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        data.songName,
                                        style: TextStyle(
                                          fontSize: screenSize.width * 0.04,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: screenSize.width * 0.25,
                            margin: EdgeInsets.only(top: screenSize.height * 0.2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Profile Picture
                                buildProfile(data.profilePhoto, screenSize.width),
                                // Like Button
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => videoController.likeVideo(data.id),
                                      child: Icon(
                                        Icons.favorite,
                                        size: screenSize.width * 0.1,
                                        color: authController.currentUser != null &&
                                            data.likes.contains(authController.currentUser!.uid)
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: screenSize.height * 0.01),

                                    Text(
                                      data.likes.length.toString(),
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.04,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                // Comment Button
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () => Get.to(() => CommentScreen(
                                        id: data.id,
                                      )),
                                      child: Icon(
                                        Icons.comment,
                                        size: screenSize.width * 0.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: screenSize.height * 0.01),
                                    Text(
                                      data.commentCount.toString(),
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.04,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                // Share Button
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        // Share functionality yahan implement karein
                                      },
                                      child: Icon(
                                        Icons.reply,
                                        size: screenSize.width * 0.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: screenSize.height * 0.01),
                                    Text(
                                      data.shareCount.toString(),
                                      style: TextStyle(
                                        fontSize: screenSize.width * 0.04,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                // Animated Music Album
                                CircleAnimation(
                                  child: buildMusicAlbum(data.profilePhoto, screenSize.width),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
