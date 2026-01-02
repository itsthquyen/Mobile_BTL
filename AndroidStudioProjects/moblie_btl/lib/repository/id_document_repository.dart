// lib/repository/id_document_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:moblie_btl/model/id_document.dart';
import 'package:moblie_btl/services/notification_service.dart';

/// Repository xử lý các thao tác CRUD cho ID Documents trên Firestore và Firebase Storage
class IdDocumentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NotificationService _notificationService = NotificationService();

  /// Lấy reference đến collection documents của một user
  CollectionReference<Map<String, dynamic>> _documentsCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('documents');
  }

  /// Stream để theo dõi tất cả documents của user
  Stream<List<IdDocument>> watchAllDocuments(String userId) {
    return _documentsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IdDocument.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Stream để theo dõi documents theo category
  Stream<List<IdDocument>> watchDocumentsByCategory(
    String userId,
    DocumentCategory category,
  ) {
    return _documentsCollection(userId)
        .where('category', isEqualTo: category.firestoreValue)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => IdDocument.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Lấy số lượng documents theo từng category
  Future<Map<DocumentCategory, int>> getDocumentCounts(String userId) async {
    Map<DocumentCategory, int> counts = {};
    for (var category in DocumentCategory.values) {
      counts[category] = 0;
    }

    final snapshot = await _documentsCollection(userId).get();
    for (var doc in snapshot.docs) {
      final category = DocumentCategory.fromString(
        doc.data()['category'] ?? 'other',
      );
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  /// Stream để theo dõi số lượng documents theo từng category
  Stream<Map<DocumentCategory, int>> watchDocumentCounts(String userId) {
    return _documentsCollection(userId).snapshots().map((snapshot) {
      Map<DocumentCategory, int> counts = {};
      for (var category in DocumentCategory.values) {
        counts[category] = 0;
      }
      for (var doc in snapshot.docs) {
        final category = DocumentCategory.fromString(
          doc.data()['category'] ?? 'other',
        );
        counts[category] = (counts[category] ?? 0) + 1;
      }
      return counts;
    });
  }

  /// Upload ảnh lên Firebase Storage và tạo document trong Firestore
  Future<IdDocument> addDocument({
    required String userId,
    required DocumentCategory category,
    required File imageFile,
    String? label,
  }) async {
    // 1. Upload ảnh lên Firebase Storage
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageRef = _storage.ref().child(
      'users/$userId/documents/$fileName',
    );

    final uploadTask = await storageRef.putFile(imageFile);
    final imageUrl = await uploadTask.ref.getDownloadURL();

    // 2. Tạo document trong Firestore
    final document = IdDocument(
      id: '', // Sẽ được cập nhật sau
      userId: userId,
      category: category,
      imageUrl: imageUrl,
      label: label,
      createdAt: DateTime.now(),
    );

    final docRef = await _documentsCollection(
      userId,
    ).add(document.toFirestore());

    // Gửi thông báo cá nhân về việc thêm tài liệu mới
    await _notificationService.notifyDocumentAdded(
      documentType: category.displayName,
    );

    return IdDocument(
      id: docRef.id,
      userId: document.userId,
      category: document.category,
      imageUrl: document.imageUrl,
      label: document.label,
      createdAt: document.createdAt,
    );
  }

  /// Xóa document và ảnh từ Storage
  Future<void> deleteDocument(String userId, IdDocument document) async {
    // 1. Xóa document từ Firestore
    await _documentsCollection(userId).doc(document.id).delete();

    // 2. Xóa ảnh từ Storage (nếu có)
    if (document.imageUrl.isNotEmpty) {
      try {
        final ref = _storage.refFromURL(document.imageUrl);
        await ref.delete();
      } catch (e) {
        // Ignore nếu không xóa được ảnh (có thể đã bị xóa từ trước)
        print('Warning: Could not delete image from storage: $e');
      }
    }

    // 3. Gửi thông báo cá nhân về việc xóa tài liệu
    await _notificationService.notifyDocumentDeleted(
      documentType: document.category.displayName,
    );
  }

  /// Cập nhật label của document
  Future<void> updateDocumentLabel(
    String userId,
    String documentId,
    String? label,
  ) async {
    await _documentsCollection(userId).doc(documentId).update({'label': label});
  }
}
