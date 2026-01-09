import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../repository/expense_controller.dart';
import '../../../../repository/trip_controller.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;

// Bỏ "Transfer"
const List<String> expenseTypes = ['Chi phí', 'Quỹ']; // Đã Việt hóa

class AddExpenseModal extends StatefulWidget {
  final String tripId;
  final VoidCallback onNavigateToFund;

  const AddExpenseModal({
    super.key,
    required this.tripId,
    required this.onNavigateToFund,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final ExpenseController _expenseController = ExpenseController();
  final TripController _tripController = TripController();
  final TextEditingController _titleController = TextEditingController(text: 'Ví dụ: Tiền ăn');
  final TextEditingController _amountController = TextEditingController(text: '0');
  final TextEditingController _dateController = TextEditingController();

  Map<String, String> _tripMembers = {};
  String? _selectedPayerUid;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _loadTripMembers();
  }

  Future<void> _loadTripMembers() async {
    setState(() => _isLoadingMembers = true);
    final members = await _tripController.getTripMembersWithNames(widget.tripId);
    if (mounted) {
      setState(() {
        _tripMembers = members;
        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserUid != null && _tripMembers.containsKey(currentUserUid)) {
          _selectedPayerUid = currentUserUid;
        }
        _isLoadingMembers = false;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_titleController.text.isEmpty || _titleController.text == 'Ví dụ: Tiền ăn') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tiêu đề chi phí')));
      return;
    }
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0')));
      return;
    }
    if (_selectedPayerUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn người trả tiền')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _expenseController.addExpense(
        tripId: widget.tripId,
        title: _titleController.text.trim(),
        amount: amount,
        payerId: _selectedPayerUid!,
        date: _selectedDate,
        tripName: 'Chuyến đi',
        memberIds: _tripMembers.keys.toList(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu chi phí: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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

  Widget _buildCustomHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          const Text('Thêm chi phí', style: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold)),
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      label: 'Tiêu đề',
      controller: _titleController,
      onTap: () {
        if (_titleController.text == 'Ví dụ: Tiền ăn') {
          _titleController.clear();
        }
      },
    );
  }

  Widget _buildAmountInput() {
    return _buildTextField(
      label: 'Số tiền',
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
        const Text('Người trả', style: TextStyle(color: Colors.white70)),
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
              hint: _isLoadingMembers
                  ? const Text('Đang tải...', style: TextStyle(color: Colors.white54))
                  : const Text('Chọn người trả', style: TextStyle(color: Colors.white54)),
              items: _tripMembers.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: _isLoadingMembers ? null : (v) => setState(() => _selectedPayerUid = v),
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
        const Text('Thời gian', style: TextStyle(color: Colors.white70)),
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
            child: Text(_dateController.text, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveExpense,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: mainBlueColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSaving ? const CircularProgressIndicator() : const Text('Thêm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
