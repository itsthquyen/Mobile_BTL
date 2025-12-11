import 'package:flutter/material.dart';

// ********************************************
// ******* 1. ĐỊNH NGHĨA MÀU SẮC & DATA *******
// ********************************************
const Color mainBlueColor = Color(0xFF153359);
const Color expenseCardColor = Color(0xFF2C436D);

// ********************************************
// ******** 2. WIDGET NỘI DUNG TAB EXPENSES ****
// ********************************************
class ExpensesTabContent extends StatelessWidget {
  const ExpensesTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          _buildSummaryCard(), // Thẻ tóm tắt tài chính

          const SizedBox(height: 20),

          // Tiêu đề Today
          const Text(
            'Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 10),

          _buildExpenseList(), // Danh sách các khoản chi tiêu

          const SizedBox(height: 100), // Khoảng trống cho FAB
        ],
      ),
    );
  }

  // Widget Thẻ Tóm Tắt Tài Chính
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mainBlueColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remaining balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Remaining balance',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 5),
              Text(
                '₫ 4.800.000',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Fund
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Fund',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              SizedBox(height: 5),
              Text(
                '₫ 9.000.000',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Danh Sách Chi Tiêu
  Widget _buildExpenseList() {
    final List<Map<String, dynamic>> expenses = [
      {'name': 'Fund', 'payer': 'All', 'amount': 9000000, 'isExpense': false},
      {'name': 'Beer', 'payer': 'Quyen', 'amount': -3000000, 'isExpense': true},
      {'name': 'Beef', 'payer': 'Lộc', 'amount': -200000, 'isExpense': true},
      {'name': 'Tiền xe', 'payer': 'Duy Hoàng Nguyên (me)', 'amount': -1000000, 'isExpense': true},
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final item = expenses[index];
        return _buildExpenseItem(
          name: item['name'],
          payer: item['payer'],
          amount: item['amount'],
          isExpense: item['isExpense'],
        );
      },
    );
  }

  // Widget từng khoản mục chi tiêu
  Widget _buildExpenseItem({
    required String name,
    required String payer,
    required int amount,
    required bool isExpense,
  }) {
    String amountText = amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
    amountText = '${isExpense ? '-' : ''}${amountText} ₫';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: expenseCardColor, // Màu card chi tiêu
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon (Currency)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.payments, size: 18, color: expenseCardColor),
            ),

            const SizedBox(width: 15),

            // Tên và Người trả
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isExpense ? 'Paid by $payer' : payer,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Số tiền
            Text(
              amountText,
              style: TextStyle(
                color: isExpense ? Colors.white : Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(width: 10),

            // Nút xóa (X)
            Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}