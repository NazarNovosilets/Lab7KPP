import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Метод для завантаження файлу та отримання його URL
  Future<String> uploadFile(File file, String userId, String fileName) async {
    try {
      // Створення посилання на шлях (наприклад, 'images/user_uid/filename.jpg') [cite: 216-217]
      final Reference storageRef = _storage.ref().child('post_images').child(userId).child(fileName);

      // Завантаження файлу
      final UploadTask uploadTask = storageRef.putFile(file); // Використання putFile() [cite: 227]
      final TaskSnapshot snapshot = await uploadTask;

      // Отримання URL для доступу [cite: 238]
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      // Обробка помилок Firebase [cite: 228-230]
      throw Exception('Помилка завантаження файлу: ${e.message}');
    } catch (e) {
      throw Exception('Виникла невідома помилка під час завантаження.');
    }
  }
}