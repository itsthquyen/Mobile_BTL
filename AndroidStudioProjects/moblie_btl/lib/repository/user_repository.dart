// lib/repository/user_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:moblie_btl/services/notification_service.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();

  /// Upload avatar image to Firebase Storage and update user's profile in Firestore
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    // 1. Upload image to Firebase Storage
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage.ref().child('users/$userId/avatar/$fileName');

    final uploadTask = await storageRef.putFile(imageFile);
    final imageUrl = await uploadTask.ref.getDownloadURL();

    // 2. Update Firestore document
    await _firestore.collection('users').doc(userId).update({
      'avatarUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. Update Firebase Auth profile (optional but good practice)
    try {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(imageUrl);
    } catch (e) {
      print('Warning: Could not update Auth photo URL: $e');
    }

    // 4. Notify profile updated
    await _notificationService.notifyProfileUpdated();

    return imageUrl;
  }
}
