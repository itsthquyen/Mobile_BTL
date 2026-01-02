// lib/repository/notification_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moblie_btl/models/app_notification.dart';

/// Repository quản lý các thao tác CRUD cho Notifications trên Firestore
///
/// Cấu trúc dữ liệu trong Firestore:
/// users/{userId}/notifications/{notificationId}
class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy reference đến collection notifications của một user
  CollectionReference<Map<String, dynamic>> _notificationsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  /// Stream để theo dõi danh sách notifications của user
  /// Sắp xếp theo thời gian mới nhất
  Stream<List<AppNotification>> watchUserNotifications(String userId) {
    return _notificationsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Stream để theo dõi số thông báo chưa đọc
  Stream<int> watchUnreadCount(String userId) {
    return _notificationsCollection(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Lấy danh sách notifications (one-time fetch)
  Future<List<AppNotification>> getUserNotifications(String userId) async {
    final snapshot = await _notificationsCollection(
      userId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs
        .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Tạo notification cho 1 user
  Future<String> createNotification(
    String userId,
    AppNotification notification,
  ) async {
    final docRef = await _notificationsCollection(
      userId,
    ).add(notification.toFirestore());
    return docRef.id;
  }

  /// Tạo notification cho nhiều users (trip members)
  /// Tạo thông báo nhóm (gửi cho nhiều người)
  Future<void> createGroupNotification(
    List<String> userIds,
    AppNotification notification,
  ) async {
    print('📨 NotificationRepository.createGroupNotification');
    print('   userIds: $userIds');
    print('   notification type: ${notification.type}');

    if (userIds.isEmpty) {
      print('   ⚠️ userIds is empty, returning');
      return;
    }

    final batch = _firestore.batch();

    for (final userId in userIds) {
      print('   Creating notification for user: $userId');
      final docRef = _notificationsCollection(userId).doc();
      final notificationWithId = notification.copyWith(id: docRef.id);
      batch.set(docRef, notificationWithId.toFirestore());
    }

    print('   💾 Committing batch...');
    await batch.commit();
    print('   ✅ Batch committed successfully');
  }

  /// Đánh dấu notification đã đọc
  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationsCollection(
      userId,
    ).doc(notificationId).update({'isRead': true});
  }

  /// Đánh dấu tất cả notifications đã đọc
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsCollection(
      userId,
    ).where('isRead', isEqualTo: false).get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Xóa notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _notificationsCollection(userId).doc(notificationId).delete();
  }

  /// Xóa tất cả notifications của user
  Future<void> deleteAllNotifications(String userId) async {
    final snapshot = await _notificationsCollection(userId).get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Xóa notifications cũ (ví dụ: notifications cũ hơn 30 ngày)
  Future<void> deleteOldNotifications(String userId, int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

    final snapshot = await _notificationsCollection(
      userId,
    ).where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate)).get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
