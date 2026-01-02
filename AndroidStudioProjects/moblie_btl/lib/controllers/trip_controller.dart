import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart'; // Sử dụng TripModel

class TripController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Helpers ---
  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  String _getRandomCoverUrl() {
    final List<String> covers = [
      'https://picsum.photos/id/1015/400/200',
      'https://picsum.photos/id/1036/400/200',
      'https://picsum.photos/id/1047/400/200',
      'https://picsum.photos/id/1050/400/200',
      'https://picsum.photos/id/164/400/200',
      'https://picsum.photos/id/28/400/200',
    ];
    return covers[Random().nextInt(covers.length)];
  }

  // --- Logic nghiệp vụ ---

  Future<String> getCurrentUserName() async {
    final user = _auth.currentUser;
    if (user == null) return '';
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['displayName'] ?? '';
      }
    } catch (e) {
      print('Error getting user name: $e');
    }
    return '';
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return {
          'uid': doc.id,
          'email': doc.data()['email'],
          'name': doc.data()['displayName'] ?? email,
        };
      }
    } catch (e) {
      print('Error finding user: $e');
    }
    return null;
  }

  Future<String> createTrip({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
    required List<Map<String, dynamic>> participants,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final joinCode = _generateJoinCode();
    final coverUrl = _getRandomCoverUrl();

    // Chuẩn bị danh sách thành viên
    Map<String, String> membersMap = {};
    for (var p in participants) {
      final uid = p['uid'] as String?;
      final role = p['role'] as String?;
      if (uid != null && uid.isNotEmpty && role != null) {
        membersMap[uid] = role;
      }
    }
    // Thêm người tạo là admin
    membersMap[user.uid] = 'admin';

    // Tạo đối tượng TripModel
    final newTrip = TripModel(
      name: title,
      coverUrl: coverUrl,
      startDate: startDate,
      endDate: endDate,
      createdBy: user.email ?? user.uid,
      joinCode: joinCode,
      members: membersMap,
      currency: currency,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Chuyển sang Map
    final tripData = newTrip.toMap();
    
    // Thêm các trường mặc định chưa có trong TripModel constructor nhưng cần thiết
    tripData['totalBudget'] = 0;
    tripData['fundTotal'] = 0;

    await _firestore.collection('trips').add(tripData);

    return joinCode;
  }

  Future<void> joinTrip(String joinCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Bạn cần đăng nhập để tham gia');

    final query = await _firestore
        .collection('trips')
        .where('joinCode', isEqualTo: joinCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Mã tham gia không hợp lệ');
    }

    final doc = query.docs.first;
    final tripId = doc.id;
    
    // 1. Convert data to Model
    final trip = TripModel.fromMap(doc.data(), docId: tripId);

    // 2. Business Logic on Model
    if (trip.members != null && trip.members!.containsKey(user.uid)) {
      throw Exception('Bạn đã tham gia chuyến đi này rồi');
    }

    // 3. Prepare data for update
    Map<String, String> updatedMembers = Map.from(trip.members ?? {});
    updatedMembers[user.uid] = 'member'; // Mặc định là member

    // 4. Update Database
    await _firestore.collection('trips').doc(tripId).update({
      'members': updatedMembers,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
