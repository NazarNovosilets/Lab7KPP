import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nickname;
  final String email;
  final String? profilePhotoUrl;

  const UserModel({
    required this.id,
    required this.nickname,
    required this.email,
    this.profilePhotoUrl,
  });

  // Фабричний конструктор для створення об'єкта з Map (Firestore Document)
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      nickname: data['nickname'] ?? '',
      email: data['email'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'],
    );
  }

  // Метод для перетворення об'єкта на Map (для запису у Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }
}