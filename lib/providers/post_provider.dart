import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';

class PostProvider with ChangeNotifier {
  final PostRepository _repository = PostRepository();
  List<Post> _posts = [];
  bool _isLoading = true; // Додано для відстеження стану завантаження
  String? _error;
  StreamSubscription? _subscription;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading; // Геттер, якого не вистачало
  String? get error => _error;

  PostProvider() {
    _startListeningToPosts();
  }

  // Реалізація синхронізації в реальному часі (Завдання 4 ЛР №6)
  void _startListeningToPosts() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _repository.getPostsStream().listen(
          (data) {
        _posts = data;
        _isLoading = false; // Завантаження завершено
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Помилка: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Метод для сумісності з main.dart
  void loadPostsWithError() {
    _startListeningToPosts();
  }

  // Редагування поста (Завдання 5 ЛР №6)
  Future<void> editPost(Post post, String newText) async {
    final user = FirebaseAuth.instance.currentUser;
    // Перевірка, що редагувати може тільки автор (Завдання 2)
    if (user != null && post.authorId == user.uid) {
      try {
        await _repository.updatePostText(post.postId, newText);
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  void togglePostLike(Post post) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _repository.toggleLike(post.postId, user.uid);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}