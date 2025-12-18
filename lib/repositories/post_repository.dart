import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Отримання потоку постів (Завдання 4)
  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Post.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Редагування тексту поста (Завдання 5)
  Future<void> updatePostText(String postId, String newText) async {
    await _firestore.collection('posts').doc(postId).update({
      'text': newText,
      'lastEdited': FieldValue.serverTimestamp(),
    });
  }

  // Логіка лайків
  Future<void> toggleLike(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = postRef.collection('likes').doc(userId);
    final doc = await likeRef.get();

    if (doc.exists) {
      await likeRef.delete();
      await postRef.update({'likesCount': FieldValue.increment(-1)});
    } else {
      await likeRef.set({'timestamp': FieldValue.serverTimestamp()});
      await postRef.update({'likesCount': FieldValue.increment(1)});
    }
  }
}