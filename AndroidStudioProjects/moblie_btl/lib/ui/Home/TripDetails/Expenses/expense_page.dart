import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ********************************************
// ******* 1. ĐỊNH NGHĨA MÀU SẮC & DATA *******
// ********************************************
const Color mainBlueColor = Color(0xFF153359);
const Color expenseCardColor = Color(0xFF2C436D);
const Color accentGoldColor = Color(0xFFEAD8B1);

// ********************************************
// ******** 2. WIDGET NỘI DUNG TAB EXPENSES ****
// ********************************************
class ExpensesTabContent extends StatefulWidget {
  final String tripId;
  const ExpensesTabContent({super.key, required this.tripId});

  @override
  State<ExpensesTabContent> createState() => _ExpensesTabContentState();
}

class _ExpensesTabContentState extends State<ExpensesTabContent> with SingleTickerProviderStateMixin {
  // Cache user names to avoid repeated fetch
  final Map<String, String> _userNames = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .collection('expenses')
          .snapshots(),
      builder: (context, expensesSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .doc(widget.tripId)
              .collection('funds')
              .snapshots(),
          builder: (context, fundsSnapshot) {
            if (expensesSnapshot.hasError || fundsSnapshot.hasError) {
              return const Center(child: Text('Lỗi khi tải dữ liệu', style: TextStyle(color: Colors.white)));
            }

            if (!expensesSnapshot.hasData || !fundsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final expensesDocs = expensesSnapshot.data!.docs;
            final fundsDocs = fundsSnapshot.data!.docs;

            // Calculate totals
            double totalExpenses = 0;
            for (var doc in expensesDocs) {
              final data = doc.data() as Map<String, dynamic>;
              totalExpenses += (data['amount'] as num?)?.toDouble() ?? 0;
            }

            double totalFunds = 0;
            for (var doc in fundsDocs) {
              final data = doc.data() as Map<String, dynamic>;
              totalFunds += (data['amount'] as num?)?.toDouble() ?? 0;
            }

            double remainingBalance = totalFunds - totalExpenses;

            // Prepare lists
            List<Map<String, dynamic>> expenseItems = [];
            for (var doc in expensesDocs) {
              final data = doc.data() as Map<String, dynamic>;
              expenseItems.add({
                'id': doc.id,
                'name': data['title'] ?? 'Chi phí',
                'payerId': data['payerId'],
                'amount': (data['amount'] as num?)?.toDouble() ?? 0,
                'date': (data['date'] as Timestamp?)?.toDate(),
                'isExpense': true,
              });
            }
            expenseItems.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

            List<Map<String, dynamic>> fundItems = [];
            for (var doc in fundsDocs) {
              final data = doc.data() as Map<String, dynamic>;
              fundItems.add({
                'id': doc.id,
                'name': (data['note'] != null && data['note'].toString().isNotEmpty) ? data['note'] : 'Đóng quỹ',
                'userId': data['userId'],
                'amount': (data['amount'] as num?)?.toDouble() ?? 0,
                'date': (data['date'] as Timestamp?)?.toDate(),
                'isExpense': false,
              });
            }
            fundItems.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSummaryCard(remainingBalance, totalFunds),
                ),
                const SizedBox(height: 15),
                // TabBar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: accentGoldColor,
                    indicatorWeight: 3,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    tabs: const [
                      Tab(text: "Hoạt động"),
                      Tab(text: "Quỹ"),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab Hoạt động (Expenses)
                      _buildTransactionList(expenseItems),
                      // Tab Quỹ (Funds)
                      _buildTransactionList(fundItems),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget Thẻ Tóm Tắt Tài Chính
  Widget _buildSummaryCard(double remaining, double totalFund) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mainBlueColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Remaining balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư còn lại',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currencyFormat.format(remaining),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        
            // Đường gạch giữa
            Container(
              width: 1,
              color: Colors.white24,
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
        
            // Fund
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Tổng quỹ',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currencyFormat.format(totalFund),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text("Chưa có giao dịch nào.", style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final payerId = item['isExpense'] ? item['payerId'] : item['userId'];

        return FutureBuilder<String>(
          future: _resolveUserName(payerId),
          builder: (context, snapshot) {
            final payerName = snapshot.data ?? '...';
            
            // Xử lý hiển thị tên cho Quỹ
            String displayName = item['name'];
            if (!item['isExpense']) {
              // Nếu là Quỹ, hiển thị tên người đóng góp thay vì "Quỹ"
              displayName = payerName;
            }

            return _buildExpenseItem(
              name: displayName,
              payer: payerName,
              amount: item['amount'],
              isExpense: item['isExpense'],
              date: item['date'],
            );
          },
        );
      },
    );
  }

  Future<String> _resolveUserName(String? uid) async {
    if (uid == null) return "Unknown";
    if (_userNames.containsKey(uid)) return _userNames[uid]!;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == uid) {
      _userNames[uid] = "Tôi";
      return "Tôi";
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final name = doc.data()?['displayName'] ?? 'Unknown';
        _userNames[uid] = name;
        return name;
      }
    } catch (e) {
      // ignore
    }
    _userNames[uid] = "Unknown";
    return "Unknown";
  }

  // Widget từng khoản mục chi tiêu
  Widget _buildExpenseItem({
    required String name,
    required String payer,
    required double amount,
    required bool isExpense,
    DateTime? date,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    String amountText = currencyFormat.format(amount);
    
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
              child: Icon(
                isExpense ? Icons.receipt_long : Icons.savings,
                size: 18, 
                color: expenseCardColor
              ),
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
                  // Logic hiển thị subtitle
                  if (isExpense) ...[
                    Text(
                      'Chi bởi $payer',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(date),
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
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
          ],
        ),
      ),
    );
  }
}
