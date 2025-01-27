// lib/views/screens/comment_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added import
import 'package:tiktok_tutorial/controllers/comment_controller.dart';

class CommentScreen extends StatelessWidget {
  final String postId;
  final CommentController commentController = Get.put(CommentController());

  CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load comments for the specified post
    commentController.fetchComments(postId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
                  () => ListView.builder(
                itemCount: commentController.comments.length,
                itemBuilder: (context, index) {
                  final comment = commentController.comments[index];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        comment['profilePic'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    title: Text(comment['username'] ?? 'Anonymous'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment['content'] ?? ''),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              comment['timestamp'] != null
                                  ? (comment['timestamp'] as Timestamp).toDate().toString()
                                  : '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(
                                comment['likes'] != null && (comment['likes'] as List).contains(commentController.auth.currentUser!.uid)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              onPressed: () => commentController.toggleLike(postId, comment['id']), // Changed 'commentId' to 'id'
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    commentController.addComment(postId, 'Your comment here');
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
