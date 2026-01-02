import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_btl/services/notification_service.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;

const List<String> expenseTypes = ['Expense', 'Fund', 'Transfer'];

class AddExpenseModal extends StatefulWidget {
  final String tripId;
  final VoidCallback onNavigateToFund;
  final VoidCallback onNavigateToTransfer;

  const AddExpenseModal({
    super.key,
    required this.tripId,
    required this.onNavigateToFund,
    required this.onNavigateToTransfer,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Ví dụ: Tiền xe',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _dateController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  Map<String, String> _tripMembers = {}; // uid -> displayName
  String? _selectedPayerUid;
  String? _tripName;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _loadTripMembers();
  }

  Future<void> _loadTripMembers() async {
    final doc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();

    if (!doc.exists) return;

    _tripName = doc.data()?['name'];
    final membersMap = doc.data()?['members'] as Map<String, dynamic>?;

    if (membersMap != null && membersMap.isNotEmpty) {
      // membersMap: {uid: role}
      // Need to fetch display names for these UIDs
      Map<String, String> memberNames = {};

      // Fetch names in parallel
      await Future.wait(
        membersMap.keys.map((uid) async {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            if (userDoc.exists) {
              memberNames[uid] = userDoc.data()?['displayName'] ?? 'Unknown';
            } else {
              memberNames[uid] = 'Unknown';
            }
          } catch (e) {
            memberNames[uid] = 'Unknown';
          }
        }),
      );

      if (mounted) {
        setState(() {
          _tripMembers = memberNames;
          // Set default payer to current user if possible, else first in list
          final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
          if (currentUserUid != null &&
              _tripMembers.containsKey(currentUserUid)) {
            _selectedPayerUid = currentUserUid;
          } else if (_tripMembers.isNotEmpty) {
            _selectedPayerUid = _tripMembers.keys.first;
          }
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedPayerUid == null)
      return;

    final amount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .collection('expenses')
        .add({
          'title': _titleController.text.trim(),
          'amount': amount,
          'payerId': _selectedPayerUid,
          'date': Timestamp.fromDate(_selectedDate),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': FirebaseAuth.instance.currentUser?.uid,
        });

    // Gửi thông báo cho các thành viên khác trong chuyến đi
    await _notificationService.notifyExpenseAdded(
      tripId: widget.tripId,
      tripName: _tripName ?? 'Chuyến đi',
      expenseTitle: _titleController.text.trim(),
      amount: amount,
      currency: 'VND',
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mainBlueColor,
      child: Column(
        children: [
          _buildCustomHeaderRow(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSegmentedControl(),
                    const SizedBox(height: 25),
                    _buildTitleInput(),
                    const SizedBox(height: 25),
                    _buildAmountInput(),
                    const SizedBox(height: 25),
                    _buildPaidByAndWhen(context),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 10,
              left: 20,
              right: 20,
            ),
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  // ================= UI (GIỮ NGUYÊN) =================

  Widget _buildCustomHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const Text(
            'Add Expense',
            style: TextStyle(
              color: lightTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildTypeSegmentedControl() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: darkFieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(expenseTypes.length, (index) {
          final isSelected = index == 0;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 1) widget.onNavigateToFund();
                if (index == 2) widget.onNavigateToTransfer();
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expenseTypes[index],
                  style: TextStyle(
                    color: isSelected ? mainBlueColor : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTitleInput() {
    return _buildTextField(
      label: 'Title',
      controller: _titleController,
      onTap: () {
        if (_titleController.text == 'Ví dụ: Tiền xe') {
          _titleController.clear();
        }
      },
    );
  }

  Widget _buildAmountInput() {
    return _buildTextField(
      label: 'Amount',
      controller: _amountController,
      keyboardType: TextInputType.number,
      onTap: () {
        if (_amountController.text == '0') {
          _amountController.clear();
        }
      },
    );
  }

  Widget _buildPaidByAndWhen(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildPaidByDropdown()),
        const SizedBox(width: 20),
        Expanded(child: _buildWhenInput(context)),
      ],
    );
  }

  Widget _buildPaidByDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paid by', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: darkFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPayerUid,
              isExpanded: true,
              dropdownColor: darkFieldColor,
              items: _tripMembers.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedPayerUid = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhenInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('When', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            height: 58,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: darkFieldColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _dateController.text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _saveExpense,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: mainBlueColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Add',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: darkFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
