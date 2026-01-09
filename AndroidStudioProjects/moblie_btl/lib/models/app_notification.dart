// lib/models/app_notification.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Enum định nghĩa các loại thông báo trong ứng dụng
enum NotificationType {
  // Trip-related notifications (gửi cho tất cả members)
  tripSchedule,
  tripExpense,
  tripFund,
  tripChecklist,
  tripVote,
  tripMember,
  tripCreated,

  // Personal notifications (chỉ gửi cho user)
  profileUpdate,
  identifyDocument,
}

/// Extension để lấy thông tin hiển thị cho từng loại notification
extension NotificationTypeExtension on NotificationType {
  /// Icon tương ứng với loại notification
  IconData get icon {
    switch (this) {
      case NotificationType.tripSchedule:
        return Icons.flight_takeoff;
      case NotificationType.tripExpense:
        return Icons.account_balance_wallet;
      case NotificationType.tripFund:
        return Icons.savings;
      case NotificationType.tripChecklist:
        return Icons.checklist_rounded;
      case NotificationType.tripVote:
        return Icons.how_to_vote;
      case NotificationType.tripMember:
        return Icons.group_add;
      case NotificationType.tripCreated:
        return Icons.explore;
      case NotificationType.profileUpdate:
        return Icons.person;
      case NotificationType.identifyDocument:
        return Icons.verified_user;
    }
  }

  /// Màu sắc tương ứng với loại notification (màu mè, đẹp mắt)
  Color get color {
    switch (this) {
      case NotificationType.tripSchedule:
        return const Color(0xFF4A90D9); // Xanh dương nhạt
      case NotificationType.tripExpense:
        return const Color(0xFFFF9F43); // Cam sáng
      case NotificationType.tripFund:
        return const Color(0xFF26DE81); // Xanh lá sáng
      case NotificationType.tripChecklist:
        return const Color(0xFF9B59B6); // Tím
      case NotificationType.tripVote:
        return const Color(0xFFE74C3C); // Đỏ coral
      case NotificationType.tripMember:
        return const Color(0xFF00CEC9); // Xanh ngọc
      case NotificationType.tripCreated:
        return const Color(0xFF6C5CE7); // Tím thanh lịch
      case NotificationType.profileUpdate:
        return const Color(0xFF6C5CE7); // Tím đậm
      case NotificationType.identifyDocument:
        return const Color(0xFF00B894); // Xanh lá đậm
    }
  }

  /// Giá trị lưu trong Firestore
  String get firestoreValue {
    switch (this) {
      case NotificationType.tripSchedule:
        return 'trip_schedule';
      case NotificationType.tripExpense:
        return 'trip_expense';
      case NotificationType.tripFund:
        return 'trip_fund';
      case NotificationType.tripChecklist:
        return 'trip_checklist';
      case NotificationType.tripVote:
        return 'trip_vote';
      case NotificationType.tripMember:
        return 'trip_member';
      case NotificationType.tripCreated:
        return 'trip_created';
      case NotificationType.profileUpdate:
        return 'profile_update';
      case NotificationType.identifyDocument:
        return 'identify_document';
    }
  }

  /// Parse từ Firestore value
  static NotificationType fromString(String value) {
    switch (value) {
      case 'trip_schedule':
        return NotificationType.tripSchedule;
      case 'trip_expense':
        return NotificationType.tripExpense;
      case 'trip_fund':
        return NotificationType.tripFund;
      case 'trip_checklist':
        return NotificationType.tripChecklist;
      case 'trip_vote':
        return NotificationType.tripVote;
      case 'trip_member':
        return NotificationType.tripMember;
      case 'trip_created':
        return NotificationType.tripCreated;
      case 'profile_update':
        return NotificationType.profileUpdate;
      case 'identify_document':
        return NotificationType.identifyDocument;
      default:
        return NotificationType.tripSchedule;
    }
  }

  /// Kiểm tra xem notification có phải là trip-related không
  bool get isTripRelated {
    switch (this) {
      case NotificationType.tripSchedule:
      case NotificationType.tripExpense:
      case NotificationType.tripFund:
      case NotificationType.tripChecklist:
      case NotificationType.tripVote:
      case NotificationType.tripMember:
      case NotificationType.tripCreated:
        return true;
      case NotificationType.profileUpdate:
      case NotificationType.identifyDocument:
        return false;
    }
  }
}

/// Model đại diện cho một thông báo trong ứng dụng
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? tripId; // Nullable - chỉ có với trip-related notifications
  final String? tripName;
  final String createdBy; // UID của người tạo thay đổi
  final String? createdByName; // Tên hiển thị của người tạo
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data; // Dữ liệu bổ sung

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.tripId,
    this.tripName,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  /// Tạo từ Firestore document
  factory AppNotification.fromFirestore(
    String docId,
    Map<String, dynamic> map,
  ) {
    DateTime parsedDate;
    final dynamic rawDate = map['createdAt'];

    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now(); // Fallback
    }

    return AppNotification(
      id: docId,
      type: NotificationTypeExtension.fromString(
        map['type'] ?? 'trip_schedule',
      ),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      tripId: map['tripId'],
      tripName: map['tripName'],
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'],
      createdAt: parsedDate,
      isRead: map['isRead'] ?? false,
      data: map['data'] != null ? Map<String, dynamic>.from(map['data']) : null,
    );
  }

  /// Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() { // Đổi tên toFirestore -> toMap
    return {
      'type': type.firestoreValue,
      'title': title,
      'body': body,
      'tripId': tripId,
      'tripName': tripName,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt), // Luôn lưu dạng Timestamp
      'isRead': isRead,
      'data': data,
    };
  }

  /// Tạo bản sao với một số field được thay đổi
  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? tripId,
    String? tripName,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      tripId: tripId ?? this.tripId,
      tripName: tripName ?? this.tripName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  /// Lấy chuỗi thời gian hiển thị dạng "3 phút trước", "1 giờ trước", etc.
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
