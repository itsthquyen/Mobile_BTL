// models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String avatarUrl;
  final String fcmToken;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.fcmToken,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'fcmToken': fcmToken,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}