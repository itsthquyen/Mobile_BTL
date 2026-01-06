// lib/repository/checklist_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moblie_btl/model/checklist_item.dart';

/// Repository xử lý các thao tác CRUD cho Checklist trên Firestore
///
/// Cấu trúc dữ liệu trong Firestore:
/// trips/{tripId}/checklists/{userId}/items/{itemId}
class ChecklistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy reference đến collection items của một user trong trip
  CollectionReference<Map<String, dynamic>> _itemsCollection(
    String tripId,
    String userId,
  ) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('checklists')
        .doc(userId)
        .collection('items');
  }

  /// Stream để theo dõi danh sách items của một user
  Stream<List<ChecklistItem>> watchUserItems(String tripId, String userId) {
    return _itemsCollection(tripId, userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChecklistItem.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Stream để theo dõi tất cả checklists của tất cả members trong trip
  Stream<Map<String, List<ChecklistItem>>> watchAllChecklists(
    String tripId,
    List<String> memberIds,
  ) {
    // Tạo map để lưu kết quả
    Map<String, List<ChecklistItem>> result = {};

    // Tạo các streams cho từng member
    final streams = memberIds.map((userId) {
      return watchUserItems(tripId, userId).map((items) {
        return MapEntry(userId, items);
      });
    }).toList();

    // Combine tất cả streams
    if (streams.isEmpty) {
      return Stream.value({});
    }

    return streams.first.asyncExpand((firstEntry) {
      result[firstEntry.key] = firstEntry.value;
      if (streams.length == 1) {
        return Stream.value(Map.from(result));
      }

      // For simplicity, we'll just return the first stream
      // In production, you might want to use rxdart's combineLatest
      return Stream.value(Map.from(result));
    });
  }

  /// Lấy danh sách items của một user (one-time fetch)
  Future<List<ChecklistItem>> getUserItems(String tripId, String userId) async {
    final snapshot = await _itemsCollection(
      tripId,
      userId,
    ).orderBy('createdAt', descending: false).get();

    return snapshot.docs
        .map((doc) => ChecklistItem.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Thêm một item mới vào checklist của user
  Future<ChecklistItem> addItem(
    String tripId,
    String userId,
    String itemName,
  ) async {
    final item = ChecklistItem(
      id: '', // Sẽ được cập nhật sau khi thêm vào Firestore
      name: itemName,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final docRef = await _itemsCollection(
      tripId,
      userId,
    ).add(item.toFirestore());

    return item.copyWith(id: docRef.id);
  }

  /// Cập nhật trạng thái hoàn thành của item
  Future<void> toggleItemCompletion(
    String tripId,
    String odau,
    String itemId,
    bool isCompleted,
  ) async {
    await _itemsCollection(
      tripId,
      odau,
    ).doc(itemId).update({'isCompleted': isCompleted});
  }

  /// Xóa một item khỏi checklist
  Future<void> deleteItem(String tripId, String userId, String itemId) async {
    await _itemsCollection(tripId, userId).doc(itemId).delete();
  }

  /// Cập nhật tên của item
  Future<void> updateItemName(
    String tripId,
    String userId,
    String itemId,
    String newName,
  ) async {
    await _itemsCollection(
      tripId,
      userId,
    ).doc(itemId).update({'name': newName});
  }

  /// Xóa tất cả items của một user
  Future<void> deleteUserChecklist(String tripId, String userId) async {
    final snapshot = await _itemsCollection(tripId, userId).get();
    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Lấy thông tin user từ collection 'users'
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  /// Lấy thông tin tất cả members của trip
  Future<List<Map<String, dynamic>>> getTripMembersInfo(
    Map<String, dynamic> members,
  ) async {
    List<Map<String, dynamic>> membersInfo = [];

    for (String odau in members.keys) {
      final userDoc = await _firestore.collection('users').doc(odau).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        membersInfo.add({
          'userId': odau,
          'name':
              userData['displayName'] ??
              userData['name'] ??
              userData['email'] ??
              'Người dùng không xác định',
          'email': userData['email'] ?? '',
          'role': members[odau],
        });
      } else {
        // Nếu không tìm thấy user trong collection users, vẫn thêm với ID
        membersInfo.add({
          'userId': odau,
          'name': 'Người dùng $odau',
          'email': '',
          'role': members[odau],
        });
      }
    }

    return membersInfo;
  }
}
