// lib/ui/Home/TripDetails/Expenses/add_transfer.dart
import 'package:flutter/material.dart';

// Định nghĩa màu sắc và dữ liệu mẫu
const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;
const Color cardBackgroundColor = Color(0xFFE8ECF2); // Màu nền của card

const List<String> expenseTypes = ['Expense', 'Fund', 'Transfer'];

// Dữ liệu mẫu cho danh sách thành viên
final List<Map<String, dynamic>> memberDebts = [
  {'name': 'Duy Hoàng Nguyễn (me)', 'amount': '3.000.000', 'isPaid': true},
  {'name': 'Lộc', 'amount': '3.000.000', 'isPaid': false},
  {'name': 'Quyên', 'amount': '3.000.000', 'isPaid': false},
];

class AddTransferModal extends StatefulWidget {
  final String tripId; // Thêm tripId
  final VoidCallback onNavigateToExpense;
  final VoidCallback onNavigateToFund;

  const AddTransferModal({
    super.key,
    required this.tripId,
    required this.onNavigateToExpense,
    required this.onNavigateToFund,
  });

  @override
  State<AddTransferModal> createState() => _AddTransferModalState();
}

class _AddTransferModalState extends State<AddTransferModal> {
  // Hàm để cập nhật trạng thái đã trả
  void _markAsPaid(int index) {
    setState(() {
      memberDebts[index]['isPaid'] = !memberDebts[index]['isPaid'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mainBlueColor,
      child: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 20),
                    // Danh sách các thành viên
                    ListView.separated(
                      shrinkWrap: true, // Để ListView nằm trong Column
                      physics: const NeverScrollableScrollPhysics(), // Không cho ListView tự cuộn
                      itemCount: memberDebts.length,
                      itemBuilder: (context, index) {
                        return _buildMemberCard(memberDebts[index], index);
                      },
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: lightTextColor, fontSize: 16)),
          ),
          const Text(
            'Transfer', // Sửa tiêu đề
            style: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: darkFieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(expenseTypes.length, (index) {
          bool isSelected = index == 2; // "Transfer" is selected
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  widget.onNavigateToExpense();
                } else if (index == 1) {
                  widget.onNavigateToFund();
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected ? null : Border.symmetric(vertical: BorderSide(color: mainBlueColor, width: 1.5)),
                ),
                child: Text(
                  expenseTypes[index],
                  style: TextStyle(
                    color: isSelected ? mainBlueColor : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member, int index) {
    bool isPaid = member['isPaid'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                member['name'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainBlueColor),
              ),
              Text(
                '₫ ${member['amount']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: mainBlueColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nút "Mark as paid"
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => _markAsPaid(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green : mainBlueColor, // Thay đổi màu khi đã trả
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Mark as paid',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}