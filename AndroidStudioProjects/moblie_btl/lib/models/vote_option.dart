import 'package:cloud_firestore/cloud_firestore.dart';

class VoteOption {
  final String id;
  final String location;
  final String? description;
  final List<String> votes; // Danh sách userId đã vote
  final String createdBy;
  final DateTime createdAt;

  VoteOption({
    required this.id,
    required this.location,
    this.description,
    required this.votes,
    required this.createdBy,
    required this.createdAt,
  });

  VoteOption copyWith({
    String? id,
    String? location,
    String? description,
    List<String>? votes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return VoteOption(
      id: id ?? this.id,
      location: location ?? this.location,
      description: description ?? this.description,
      votes: votes ?? this.votes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Chuyển từ Firestore Document sang Object
  factory VoteOption.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime parsedDate;
    final dynamic rawDate = data['createdAt'];

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now(); // Fallback
    }

    return VoteOption(
      id: id,
      location: data['location'] ?? '',
      description: data['description'],
      votes: List<String>.from(data['votes'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: parsedDate,
    );
  }

  // Chuyển từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'description': description,
      'votes': votes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
