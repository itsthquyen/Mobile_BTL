import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String name;       // Firestore field: name
  final String coverUrl;   // Firestore field: coverUrl
  final int memberCount;
  final Map<String, dynamic> members; // Firestore field: members
  final DateTime? startDate;
  final String? joinCode;   // THÊM TRƯỜNG joinCode

  Trip({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.members,
    this.memberCount = 0,
    this.startDate,
    this.joinCode,
  });

  // Factory constructor để tạo Trip từ Firestore Document
  factory Trip.fromFirestore(String id, Map<String, dynamic> data) {
    Map<String, dynamic> membersMap = {};
    if (data['members'] != null && data['members'] is Map) {
      final rawMap = data['members'] as Map;
      membersMap = rawMap.map((key, value) => MapEntry(key.toString(), value));
    }

    DateTime? start;
    if (data['startDate'] != null && data['startDate'] is Timestamp) {
      start = (data['startDate'] as Timestamp).toDate();
    }

    return Trip(
      id: id,
      name: data['name'] ?? 'Untitled Trip',
      coverUrl: data['coverUrl'] ?? 'https://picsum.photos/400/200',
      members: membersMap,
      memberCount: membersMap.length,
      startDate: start,
      joinCode: data['joinCode'] as String?, // LẤY joinCode TỪ FIRESTORE
    );
  }
}