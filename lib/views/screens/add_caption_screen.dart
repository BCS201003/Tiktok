//lib/view/add_caption_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';

class AddCaptionScreen extends StatelessWidget {
  final File? videoFile;
  final String videoPath;

  const AddCaptionScreen({Key? key, this.videoFile, required this.videoPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
          ),
        ]
      ),
    );
  }
}
