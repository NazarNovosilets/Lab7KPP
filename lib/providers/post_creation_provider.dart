import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

enum PostCreationStatus { idle, loading, success, error }

class PostCreationProvider with ChangeNotifier {
  Uint8List? _selectedPhotoBytes;
  PostCreationStatus _status = PostCreationStatus.idle;
  String? _errorMessage;

  Uint8List? get selectedPhotoBytes => _selectedPhotoBytes;
  PostCreationStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void setSelectedPhoto(Uint8List? bytes) {
    _selectedPhotoBytes = bytes;
    _status = PostCreationStatus.idle;
    notifyListeners();
  }

  void reset() {
    _selectedPhotoBytes = null;
    _status = PostCreationStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> createPost({required String text}) async {
    if (_selectedPhotoBytes == null) return;
    _status = PostCreationStatus.loading;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Необхідна авторизація");

      final postId = const Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child('posts/${user.uid}/$postId.jpg');

      // Завантаження байтів (Завдання 6)
      final uploadTask = await storageRef.putData(_selectedPhotoBytes!, SettableMetadata(contentType: 'image/jpeg'));
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Запис у Firestore (Завдання 5)
      await FirebaseFirestore.instance.collection('posts').doc(postId).set({
        'postId': postId,
        'authorId': user.uid,
        'username': user.email?.split('@')[0] ?? 'Користувач',
        'text': text,
        'images': [imageUrl],
        'likesCount': 0,
        'commentsCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _status = PostCreationStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = PostCreationStatus.error;
    } finally {
      notifyListeners();
    }
  }
}