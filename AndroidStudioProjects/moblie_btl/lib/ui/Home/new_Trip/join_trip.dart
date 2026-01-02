// lib/ui/trip/join_trip_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_btl/services/notification_service.dart';

// ===== CONSTANTS =====
const primaryColor = Color(0xFF153359);
const inputFillColor = Color(0xFFF0F0FF);

class JoinTripPage extends StatefulWidget {
  const JoinTripPage({super.key});

  @override
  State<JoinTripPage> createState() => _JoinTripPageState();
}

class _JoinTripPageState extends State<JoinTripPage> {
  final TextEditingController _linkController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  // ===== LOAD USER DISPLAY NAME =====
  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      setState(() {
        _displayName = doc.data()?['displayName'] ?? '';
      });
    }
  }

  // ===== JOIN TRIP =====
  Future<void> _joinTrip() async {
    final joinCode = _linkController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (joinCode.isEmpty) {
      _showMessage('Vui lòng nhập mã mời');
      return;
    }

    if (user == null) {
      _showMessage('Bạn cần đăng nhập để tham gia');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection('trips')
          .where('joinCode', isEqualTo: joinCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _showMessage('Mã tham gia không hợp lệ');
        return;
      }

      final tripDoc = query.docs.first;
      final tripId = tripDoc.id;
      final tripName = tripDoc.data()['name'] ?? 'Chuyến đi';

      final members = Map<String, dynamic>.from(
        tripDoc.data()['members'] ?? {},
      );

      if (members.containsKey(user.uid)) {
        _showMessage('Bạn đã tham gia chuyến đi này rồi');
        return;
      }

      await FirebaseFirestore.instance.collection('trips').doc(tripId).update({
        'members.${user.uid}': 'member',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Gửi thông báo cho các thành viên hiện có trong chuyến đi
      print('📢 JoinTripPage: Calling notifyMemberJoined');
      await _notificationService.notifyMemberJoined(
        tripId: tripId,
        tripName: tripName,
        memberName: _displayName.isNotEmpty ? _displayName : 'Thành viên mới',
      );

      _showMessage('🎉 Tham gia chuyến đi thành công!');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Có lỗi xảy ra');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ===== HEADER =====
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            width: double.infinity,
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TripSync',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _displayName.isNotEmpty
                          ? 'Hi, $_displayName! 👋'
                          : 'Hi! 👋',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tham gia chuyến đi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Yêu cầu bạn bè gửi mã tham gia và nhập vào ô bên dưới.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Mã mời',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã tại đây',
                      filled: true,
                      fillColor: inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _joinTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Tham gia',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
