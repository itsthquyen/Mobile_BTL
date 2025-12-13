// lib/ui/Home/TripDetails/CheckList/checklist_tab.dart
import 'package:flutter/material.dart';
// Import file chứa trang chi tiết.
// Tên file này có thể là 'checklist_item_dialog.dart' hoặc 'member_checklist_page.dart' tùy bạn đặt.
import 'checklist_item_dialog.dart';

// Giả định màu sắc và các hằng số
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

// Cấu trúc dữ liệu mẫu: Danh sách các thành viên và vật dụng của họ.
// Dữ liệu này sau này bạn sẽ lấy từ API hoặc cơ sở dữ liệu.
final List<Map<String, dynamic>> memberChecklists = [
  {
    'name': 'Duy Hoàng Nguyễn (me)',
    'avatar': Icons.person_pin_circle, // Icon đại diện
    'items': [
      {'name': 'Passport', 'isCompleted': true},
      {'name': 'Sunscreen', 'isCompleted': false},
      {'name': 'Phone Charger', 'isCompleted': true},
    ],
  },
  {
    'name': 'Lộc',
    'avatar': Icons.boy_rounded,
    'items': [
      {'name': 'Umbrella', 'isCompleted': false},
      {'name': 'Snacks', 'isCompleted': false},
    ],
  },
  {
    'name': 'Quyên',
    'avatar': Icons.girl_rounded,
    'items': [
      {'name': 'Swimsuit', 'isCompleted': true},
      {'name': 'Towel', 'isCompleted': false},
      {'name': 'Camera', 'isCompleted': false},
    ],
  },
];

class ChecklistTabContent extends StatelessWidget {
  const ChecklistTabContent({super.key});

  // Hàm điều hướng sang trang chi tiết checklist của thành viên
  void _navigateToMemberChecklist(BuildContext context, Map<String, dynamic> memberData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Điều hướng tới MemberChecklistPage và truyền dữ liệu của thành viên đó qua
        builder: (context) => MemberChecklistPage(memberData: memberData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: ListView.separated(
        itemCount: memberChecklists.length,
        itemBuilder: (context, index) {
          // Build giao diện cho từng thành viên
          return _buildMemberItem(context, memberChecklists[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 15),
      ),
    );
  }

  // Widget cho mỗi card thành viên trong danh sách
  Widget _buildMemberItem(BuildContext context, Map<String, dynamic> memberData) {
    // Tính toán tiến độ công việc để hiển thị
    final items = memberData['items'] as List;
    final totalCount = items.length;
    final completedCount = items.where((item) => item['isCompleted'] as bool).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: mainBlueColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar và Tên
          Icon(memberData['avatar'] as IconData, color: accentGoldColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberData['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (totalCount > 0) ...[
                  const SizedBox(height: 4),
                  // Hiển thị tiến độ (ví dụ: 2/3 items completed)
                  Text(
                    '$completedCount/$totalCount items completed',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ]
              ],
            ),
          ),
          // Nút "See item"
          ElevatedButton(
            onPressed: () {
              // Gọi hàm điều hướng khi nhấn nút
              _navigateToMemberChecklist(context, memberData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: mainBlueColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('See item'),
          ),
        ],
      ),
    );
  }
}
