// lib/ui/Home/TripDetails/Expenses/add_fund.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblie_btl/services/notification_service.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;

const List<String> expenseTypes = ['Expense', 'Fund', 'Transfer'];

class AddFundModal extends StatefulWidget {
  final String tripId;
  final VoidCallback onNavigateToExpense;
  final VoidCallback onNavigateToTransfer;

  const AddFundModal({
    super.key,
    required this.tripId,
    required this.onNavigateToExpense,
    required this.onNavigateToTransfer,
  });

  @override
  State<AddFundModal> createState() => _AddFundModalState();
}

class _AddFundModalState extends State<AddFundModal> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Quỹ',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _dateController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  Map<String, String> _tripMembers = {};
  String? _selectedPayerUid;
  String? _tripName;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false; // Trạng thái đang lưu

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _loadTripMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadTripMembers() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (!doc.exists) return;

      _tripName = doc.data()?['name'];
      final membersMap = doc.data()?['members'] as Map<String, dynamic>?;

      if (membersMap != null && membersMap.isNotEmpty) {
        Map<String, String> memberNames = {};

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
    } catch (e) {
      print("Error loading members: $e");
    }
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day.toString().padLeft(2, '0')} ${monthNames[date.month - 1]} ${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: mainBlueColor,
              onPrimary: lightTextColor,
              surface: darkFieldColor,
              onSurface: lightTextColor,
            ),
            dialogBackgroundColor: mainBlueColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _addFund() async {
    // 1. Validation rõ ràng
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung quỹ')),
      );
      return;
    }
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền')),
      );
      return;
    }
    if (_selectedPayerUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người đóng góp')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final amount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

    print("--- Bắt đầu thêm quỹ ---");
    print("TripID: ${widget.tripId}");
    print("Payer: $_selectedPayerUid");
    print("Amount: $amount");

    try {
      // 2. Thêm vào Firestore
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .collection('funds')
          .add({
            'userId': _selectedPayerUid,
            'amount': amount,
            'currency': 'VND',
            'date': Timestamp.fromDate(_selectedDate),
            'note': _titleController.text.trim(),
            'proofImage': '',
            'createdAt': FieldValue.serverTimestamp(),
          });
      
      print("Đã lưu vào Firestore thành công");

      // 3. Gửi thông báo (trong try-catch riêng để không chặn flow chính)
      try {
        await _notificationService.notifyFundAdded(
          tripId: widget.tripId,
          tripName: _tripName ?? 'Chuyến đi',
          fundTitle: _titleController.text.trim(),
          amount: amount,
          currency: 'VND',
        );
        print("Đã gửi thông báo thành công");
      } catch (notiError) {
        print("Lỗi gửi thông báo: $notiError");
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm quỹ thành công!')),
        );
      }
    } catch (e) {
      print("Lỗi khi thêm quỹ: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: 25),
                    _buildTitleInput(),
                    const SizedBox(height: 25),
                    _buildAmountInput(),
                    const SizedBox(height: 25),
                    _buildPaidByDropdown(),
                    const SizedBox(height: 25),
                    _buildWhenInput(context),
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
              top: 10,
            ),
            child: _buildAddButton(),
          ),
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
          bool isSelected = index == 1;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (index == 0) {
                  widget.onNavigateToExpense();
                } else if (index == 2) {
                  widget.onNavigateToTransfer();
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? null
                      : Border.symmetric(
                          vertical: BorderSide(
                            color: mainBlueColor,
                            width: 1.5,
                          ),
                        ),
                ),
                child: Text(
                  expenseTypes[index],
                  style: TextStyle(
                    color: isSelected ? mainBlueColor : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: lightTextColor, fontSize: 16),
            ),
          ),
          const Text(
            'Add Fund',
            style: TextStyle(
              color: lightTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note / Title',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          // Xóa decoration cứng, dùng TextField để có thể edit nếu muốn (hoặc Container như cũ)
          // Theo yêu cầu trước là "Quỹ" mặc định nhưng vẫn dùng Container. 
          // Ở đây tôi đổi thành TextField readonly để đồng bộ style
          decoration: BoxDecoration(
            color: darkFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _titleController,
            readOnly: true, // Không cho sửa tiêu đề Quỹ theo yêu cầu cũ
            style: const TextStyle(color: lightTextColor, fontSize: 16),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: darkFieldColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text(
                    '₫',
                    style: TextStyle(color: lightTextColor, fontSize: 20),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.unfold_more_sharp,
                    color: lightTextColor,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\.]')),
                ],
                style: const TextStyle(
                  color: lightTextColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 16.5,
                  ),
                  filled: true,
                  fillColor: darkFieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onTap: () {
                  if (_amountController.text == '0') {
                    _amountController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaidByDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contributed by',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
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
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white70,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              // Hint hiển thị khi chưa chọn hoặc đang load
              hint: _tripMembers.isEmpty 
                  ? const Text("Đang tải...", style: TextStyle(color: Colors.white54))
                  : const Text("Chọn thành viên", style: TextStyle(color: Colors.white)),
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
        const Text(
          'When',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: darkFieldColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dateController.text,
                  style: const TextStyle(color: lightTextColor, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _addFund,
      style: ElevatedButton.styleFrom(
        backgroundColor: lightTextColor,
        foregroundColor: mainBlueColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _isSaving
          ? const CircularProgressIndicator()
          : const Text(
              'Add',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}
