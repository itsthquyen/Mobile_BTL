// lib/repository/vote_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moblie_btl/model/vote_option.dart';

/// Repository xử lý các thao tác CRUD cho Vote trên Firestore
///
/// Cấu trúc dữ liệu trong Firestore:
/// trips/{tripId}/votes/{voteId}
class VoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy reference đến collection votes của một trip
  CollectionReference<Map<String, dynamic>> _votesCollection(String tripId) {
    return _firestore.collection('trips').doc(tripId).collection('votes');
  }

  /// Stream để theo dõi danh sách vote options (realtime)
  Stream<List<VoteOption>> watchVoteOptions(String tripId) {
    return _votesCollection(tripId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VoteOption.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Lấy danh sách vote options (one-time fetch)
  Future<List<VoteOption>> getVoteOptions(String tripId) async {
    final snapshot = await _votesCollection(
      tripId,
    ).orderBy('createdAt', descending: false).get();

    return snapshot.docs
        .map((doc) => VoteOption.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Thêm một vote option mới
  Future<VoteOption> addVoteOption({
    required String tripId,
    required String location,
    String? description,
    String? imageUrl,
    required String createdBy,
  }) async {
    final option = VoteOption(
      id: '',
      location: location,
      description: description,
      imageUrl: imageUrl,
      votes: [],
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );

    final docRef = await _votesCollection(tripId).add(option.toFirestore());
    return option.copyWith(id: docRef.id);
  }

  /// Toggle vote của user cho một option
  Future<void> toggleVote(String tripId, String optionId, String odau) async {
    final docRef = _votesCollection(tripId).doc(optionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final votes = List<String>.from(snapshot.data()?['votes'] ?? []);

      if (votes.contains(odau)) {
        votes.remove(odau);
      } else {
        votes.add(odau);
      }

      transaction.update(docRef, {'votes': votes});
    });
  }

  /// Xóa một vote option
  Future<void> deleteVoteOption(String tripId, String optionId) async {
    await _votesCollection(tripId).doc(optionId).delete();
  }

  /// Lấy thông tin user từ collection 'users'
  Future<Map<String, String>> getMemberNames(List<String> userIds) async {
    Map<String, String> names = {};

    for (String odau in userIds) {
      final doc = await _firestore.collection('users').doc(odau).get();
      if (doc.exists) {
        final data = doc.data()!;
        names[odau] =
            data['displayName'] ??
            data['name'] ??
            data['email'] ??
            'Người dùng';
      } else {
        names[odau] = 'Người dùng';
      }
    }

    return names;
  }
}
