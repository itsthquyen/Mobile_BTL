// lib/model/vote_option.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một lựa chọn bình chọn địa điểm
class VoteOption {
  final String id;
  final String location;
  final String? description;
  final String? imageUrl;
  final List<String> votes; // List of user IDs who voted
  final String createdBy;
  final DateTime createdAt;

  VoteOption({
    required this.id,
    required this.location,
    this.description,
    this.imageUrl,
    required this.votes,
    required this.createdBy,
    required this.createdAt,
  });

  /// Factory constructor để tạo VoteOption từ Firestore Document
  factory VoteOption.fromFirestore(String id, Map<String, dynamic> data) {
    return VoteOption(
      id: id,
      location: data['location'] ?? '',
      description: data['description'],
      imageUrl: data['imageUrl'],
      votes: List<String>.from(data['votes'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'votes': votes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  VoteOption copyWith({
    String? id,
    String? location,
    String? description,
    String? imageUrl,
    List<String>? votes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return VoteOption(
      id: id ?? this.id,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      votes: votes ?? this.votes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
