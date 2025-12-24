import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ********************************************
// ******* 1. ĐỊNH NGHĨA MÀU SẮC & DATA *******
// ********************************************
const Color mainBlueColor = Color(0xFF153359);
const Color expenseCardColor = Color(0xFF2C436D);

// ********************************************
// ******** 2. WIDGET NỘI DUNG TAB EXPENSES ****
// ********************************************
class ExpensesTabContent extends StatefulWidget {
  final String tripId;
  const ExpensesTabContent({super.key, required this.tripId});

  @override
  State<ExpensesTabContent> createState() => _ExpensesTabContentState();
}

class _ExpensesTabContentState extends State<ExpensesTabContent> {
  // Cache user names to avoid repeated fetch
  final Map<String, String> _userNames = {};

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
              return const Center(child: Text('Error loading data', style: TextStyle(color: Colors.white)));
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

            // Merge and sort items
            List<Map<String, dynamic>> items = [];

            for (var doc in expensesDocs) {
              final data = doc.data() as Map<String, dynamic>;
              items.add({
                'id': doc.id,
                'name': data['title'] ?? 'Expense',
                'payerId': data['payerId'],
                'amount': (data['amount'] as num?)?.toDouble() ?? 0,
                'date': (data['date'] as Timestamp?)?.toDate(),
                'isExpense': true,
              });
            }

            for (var doc in fundsDocs) {
              final data = doc.data() as Map<String, dynamic>;
              items.add({
                'id': doc.id,
                'name': (data['note'] != null && data['note'].toString().isNotEmpty) ? data['note'] : 'Fund Contribution',
                'userId': data['userId'],
                'amount': (data['amount'] as num?)?.toDouble() ?? 0,
                'date': (data['date'] as Timestamp?)?.toDate(),
                'isExpense': false,
              });
            }

            // Sort by date descending
            items.sort((a, b) {
              DateTime da = a['date'] ?? DateTime(1970);
              DateTime db = b['date'] ?? DateTime(1970);
              return db.compareTo(da);
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  _buildSummaryCard(remainingBalance, totalFunds),

                  const SizedBox(height: 20),

                  // Header
                  if (items.isNotEmpty)
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),

                  const SizedBox(height: 10),

                  _buildTransactionList(items),

                  const SizedBox(height: 100), // Khoảng trống cho FAB
                ],
              ),
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
            children: [
              const Text(
                'Remaining balance',
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

          // Fund
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Fund',
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
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return const Center(child: Text("No transactions yet.", style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final payerId = item['isExpense'] ? item['payerId'] : item['userId'];

        return FutureBuilder<String>(
          future: _resolveUserName(payerId),
          builder: (context, snapshot) {
            final payerName = snapshot.data ?? '...';
            return _buildExpenseItem(
              name: item['name'],
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
      _userNames[uid] = "Me";
      return "Me";
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
    amountText = '${isExpense ? '-' : ''}$amountText';

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
                  Text(
                    isExpense ? 'Paid by $payer' : 'Contributed by $payer',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
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

            const SizedBox(width: 10),

            // Nút xóa (X) - Có thể thêm chức năng xóa sau này
            // Icon(
            //   Icons.close,
            //   color: Colors.white.withOpacity(0.5),
            //   size: 18,
            // ),
          ],
        ),
      ),
    );
  }
}
