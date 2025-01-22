// lib/views/screens/comment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_tutorial/constants.dart';
import 'package:tiktok_tutorial/controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as tago;

class CommentScreen extends StatefulWidget {
  final String id;
  const CommentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  final CommentController commentController = Get.put(CommentController());

  @override
  void initState() {
    super.initState();
    commentController.updatePostId(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (commentController.comments.isEmpty) {
                return const Center(
                  child: Text(
                    'No comments yet.',
                    style: TextStyle(color: Colors.black),
                  ),
                );
              }
              return ListView.builder(
                itemCount: commentController.comments.length,
                itemBuilder: (context, index) {
                  final comment = commentController.comments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.black,
                      backgroundImage: File(comment.profilePhoto).existsSync()
                          ? FileImage(File(comment.profilePhoto))
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    title: Row(
                      children: [
                        Text(
                          "${comment.username}  ",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            comment.comment,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          tago.format(
                            comment.datePublished.toDate(),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${comment.likes.length} likes',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () =>
                          commentController.likeComment(comment.id),
                      child: Icon(
                        Icons.favorite,
                        size: 25,
                        color: comment.likes
                            .contains(authController.currentUser!.uid)
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _commentController,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    String commentText = _commentController.text.trim();
                    if (commentText.isNotEmpty) {
                      commentController.postComment(commentText);
                      _commentController.clear();
                    }
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
