import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  // Фабричний конструктор для створення об'єкта з Map (Firestore Document)
  factory CommentModel.fromMap(String id, Map<String, dynamic> data) {
    return CommentModel(
      id: id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Метод для перетворення об'єкта на Map (для запису у Firestore)
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}