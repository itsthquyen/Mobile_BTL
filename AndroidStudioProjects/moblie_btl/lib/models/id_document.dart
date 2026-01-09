// lib/model/id_document.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum cho các loại tài liệu định danh
enum DocumentCategory {
  passport,
  idCard,
  driverLicense,
  other;

  String get displayName {
    switch (this) {
      case DocumentCategory.passport:
        return 'Hộ chiếu';
      case DocumentCategory.idCard:
        return 'CCCD/CMND';
      case DocumentCategory.driverLicense:
        return 'Bằng lái xe';
      case DocumentCategory.other:
        return 'Khác';
    }
  }

  String get firestoreValue {
    switch (this) {
      case DocumentCategory.passport:
        return 'passport';
      case DocumentCategory.idCard:
        return 'id_card';
      case DocumentCategory.driverLicense:
        return 'driver_license';
      case DocumentCategory.other:
        return 'other';
    }
  }

  static DocumentCategory fromString(String value) {
    switch (value) {
      case 'passport':
        return DocumentCategory.passport;
      case 'id_card':
        return DocumentCategory.idCard;
      case 'driver_license':
        return DocumentCategory.driverLicense;
      default:
        return DocumentCategory.other;
    }
  }
}

/// Model đại diện cho một tài liệu định danh (ID)
class IdDocument {
  final String id;
  final String userId;
  final DocumentCategory category;
  final String imageUrl;
  final String? label;
  final DateTime createdAt;

  IdDocument({
    required this.id,
    required this.userId,
    required this.category,
    required this.imageUrl,
    this.label,
    required this.createdAt,
  });

  /// Factory constructor để tạo IdDocument từ Firestore Document
  factory IdDocument.fromFirestore(String id, Map<String, dynamic> data) {
    return IdDocument(
      id: id,
      userId: data['userId'] ?? '',
      category: DocumentCategory.fromString(data['category'] ?? 'other'),
      imageUrl: data['imageUrl'] ?? '',
      label: data['label'] as String?,
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category.firestoreValue,
      'imageUrl': imageUrl,
      'label': label,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
