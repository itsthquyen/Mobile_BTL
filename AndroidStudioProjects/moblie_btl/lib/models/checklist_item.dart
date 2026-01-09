// lib/model/checklist_item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model đại diện cho một item trong checklist
class ChecklistItem {
  final String id;
  final String name;
  final bool isCompleted;
  final DateTime createdAt;

  ChecklistItem({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
  });

  /// Factory constructor để tạo ChecklistItem từ Firestore Document
  factory ChecklistItem.fromFirestore(String id, Map<String, dynamic> data) {
    return ChecklistItem(
      id: id,
      name: data['name'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Chuyển đổi sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  ChecklistItem copyWith({
    String? id,
    String? name,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model đại diện cho checklist của một thành viên
class MemberChecklist {
  final String odau;
  final String odauName;
  final String odauEmail;
  final List<ChecklistItem> items;

  MemberChecklist({
    required this.odau,
    required this.odauName,
    required this.odauEmail,
    required this.items,
  });

  /// Tính số item đã hoàn thành
  int get completedCount => items.where((item) => item.isCompleted).length;

  /// Tính tổng số item
  int get totalCount => items.length;

  /// Tính phần trăm hoàn thành
  double get completionPercentage =>
      totalCount > 0 ? completedCount / totalCount : 0;
}
