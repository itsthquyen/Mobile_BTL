import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_schedule.dart'; // Import để có thể gọi modal

const primaryColor = Color(0xFF153359);
const accentGoldColor = Color(0xFFEAD8B1); 

class ScheduleTabContent extends StatelessWidget {
  final String tripId;

  const ScheduleTabContent({super.key, required this.tripId});

  Stream<QuerySnapshot> _getScheduleStream() {
    return FirebaseFirestore.instance
        .collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .orderBy('startTime', descending: false)
        .snapshots();
  }

  String _formatDateTime(DateTime dt, String format) {
    const monthNames = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    const dayNames = ['Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];

    if (format == 'EEEE, dd MMMM yyyy') {
      return '${dayNames[dt.weekday - 1]}, ${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
    }
    if (format == 'HH:mm') {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return dt.toString();
  }
  
  // --- HÀM MỞ MODAL CHỈNH SỬA ---
  void _showEditScheduleModal(BuildContext context, String scheduleId, Map<String, dynamic> scheduleData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: AddScheduleModal(
            tripId: tripId,
            scheduleId: scheduleId, // Truyền ID của lịch trình
            scheduleData: scheduleData, // Truyền dữ liệu lịch trình
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user để kiểm tra vai trò
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: _getScheduleStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final scheduleDocs = snapshot.data!.docs;

        Map<DateTime, List<QueryDocumentSnapshot>> groupedByDay = {};
        for (var doc in scheduleDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final startTime = (data['startTime'] as Timestamp).toDate();
          final day = DateTime(startTime.year, startTime.month, startTime.day);

          if (groupedByDay[day] == null) {
            groupedByDay[day] = [];
          }
          groupedByDay[day]!.add(doc);
        }

        final sortedDays = groupedByDay.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          itemCount: sortedDays.length,
          itemBuilder: (context, index) {
            final day = sortedDays[index];
            final items = groupedByDay[day]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                  child: Text(
                    _formatDateTime(day, 'EEEE, dd MMMM yyyy'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                // Truyền context vào _buildScheduleItem
                ...items.map((doc) => _buildScheduleItem(context, doc.id, doc.data() as Map<String, dynamic>, user?.uid)).toList(),
              ],
            );
          },
        );
      },
    );
  }

  // --- WIDGET CHO MỘT LỊCH TRÌNH (SỬA LẠI ĐỂ NHẬN CONTEXT VÀ UID) ---
  Widget _buildScheduleItem(BuildContext context, String docId, Map<String, dynamic> data, String? currentUserId) {
    final startTime = (data['startTime'] as Timestamp).toDate();
    final endTime = (data['endTime'] as Timestamp).toDate();
    
    // Tạm thời lấy role từ member list, sau này có thể truyền trực tiếp
    final isAdmin = true; // Giả sử user là admin để test, bạn sẽ cần logic lấy role thật

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: isAdmin ? () => _showEditScheduleModal(context, docId, data) : null,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 8,
                decoration: const BoxDecoration(
                  color: accentGoldColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_formatDateTime(startTime, 'HH:mm'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const Text('-', style: TextStyle(color: Colors.white70)),
                    Text(_formatDateTime(endTime, 'HH:mm'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'] ?? 'Không có tiêu đề', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      if (data['locationName'] != null && data['locationName'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  data['locationName'],
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isAdmin) // Chỉ admin mới thấy nút mũi tên
                const Icon(Icons.chevron_right, color: Colors.white),
                const SizedBox(width: 8) // Thêm padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded, size: 80, color: accentGoldColor.withValues(alpha: 0.8)),
          const SizedBox(height: 16),
          const Text(
            "Chưa có lịch trình",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Nhấn nút "+" để bắt đầu tạo lịch trình cho chuyến đi của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
