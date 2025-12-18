import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String authorId;
  final String username;
  final String text;
  final List<String> images;
  final int likes;
  final int comments;
  final DateTime timestamp;
  final bool isLiked;

  Post({
    required this.postId,
    required this.authorId,
    required this.username,
    required this.text,
    required this.images,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isLiked = false,
  });

  factory Post.fromMap(Map<String, dynamic> data, String id) {
    final timestamp = data['timestamp'] as Timestamp?;
    return Post(
      postId: id,
      authorId: data['authorId'] ?? '',
      username: data['username'] ?? 'Анонім',
      text: data['text'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      likes: data['likesCount'] ?? 0,
      comments: data['commentsCount'] ?? 0,
      timestamp: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Post copyWith({int? likes, bool? isLiked}) {
    return Post(
      postId: postId,
      authorId: authorId,
      username: username,
      text: text,
      images: images,
      likes: likes ?? this.likes,
      comments: comments,
      timestamp: timestamp,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}