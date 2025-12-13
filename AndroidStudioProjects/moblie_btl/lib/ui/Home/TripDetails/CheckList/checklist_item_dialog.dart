// lib/ui/Home/TripDetails/CheckList/checklist_item_dialog.dart
import 'package:flutter/material.dart';

// Giả định màu sắc
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class MemberChecklistPage extends StatefulWidget {
  // Nhận dữ liệu của thành viên được chọn từ màn hình trước
  final Map<String, dynamic> memberData;

  const MemberChecklistPage({super.key, required this.memberData});

  @override
  State<MemberChecklistPage> createState() => _MemberChecklistPageState();
}

class _MemberChecklistPageState extends State<MemberChecklistPage> {
  // Dùng một list stateful để có thể thay đổi trạng thái isCompleted
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    // Sao chép list từ widget (dữ liệu truyền vào) sang state để có thể thay đổi trong màn hình này
    _items = List<Map<String, dynamic>>.from(widget.memberData['items'] as List);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBlueColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Hiển thị tên thành viên trên thanh tiêu đề
        title: Text(
          "${widget.memberData['name']}'s Checklist",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.separated(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            return _buildItem(index);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ),
    );
  }

  // Widget cho mỗi vật dụng trong danh sách
  Widget _buildItem(int index) {
    var item = _items[index];
    bool isCompleted = item['isCompleted'] as bool;

    return GestureDetector(
      onTap: () {
        setState(() {
          // Khi người dùng nhấn vào cả card, đảo ngược trạng thái completed của vật dụng đó
          _items[index]['isCompleted'] = !isCompleted;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon checkbox
            Icon(
              isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: isCompleted ? Colors.greenAccent : accentGoldColor,
              size: 26,
            ),
            const SizedBox(width: 16),
            // Tên vật dụng
            Expanded(
              child: Text(
                item['name'] as String,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  // Thêm hiệu ứng gạch ngang nếu đã hoàn thành
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white70,
                  decorationThickness: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
