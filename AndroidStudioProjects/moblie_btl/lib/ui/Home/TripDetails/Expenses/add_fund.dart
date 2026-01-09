import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../repository/expense_controller.dart';
import '../../../../repository/trip_controller.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;

const List<String> expenseTypes = ['Chi phí', 'Quỹ'];

class AddFundModal extends StatefulWidget {
  final String tripId;
  final VoidCallback onNavigateToExpense;

  const AddFundModal({
    super.key,
    required this.tripId,
    required this.onNavigateToExpense,
  });

  @override
  State<AddFundModal> createState() => _AddFundModalState();
}

class _AddFundModalState extends State<AddFundModal> {
  final ExpenseController _expenseController = ExpenseController();
  final TripController _tripController = TripController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
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
    final members = await _tripController.getTripMembersWithNames(
      widget.tripId,
    );
    if (mounted) {
      setState(() {
        _tripMembers = members;
        final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserUid != null &&
            _tripMembers.containsKey(currentUserUid)) {
          _selectedPayerUid = currentUserUid;
        }
        _isLoadingMembers = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _addFund() async {
    if (_selectedPayerUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người đóng góp')),
      );
      return;
    }

    final amount =
        double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _expenseController.addFund(
        tripId: widget.tripId,
        amount: amount,
        userId: _selectedPayerUid!,
        date: _selectedDate,
        tripName: 'Chuyến đi',
        memberIds: _tripMembers.keys.toList(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      "T1",
      "T2",
      "T3",
      "T4",
      "T5",
      "T6",
      "T7",
      "T8",
      "T9",
      "T10",
      "T11",
      "T12",
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
            dialogTheme: DialogThemeData(backgroundColor: mainBlueColor),
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

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(color: lightTextColor, fontSize: 16),
            ),
          ),
          const Text(
            'Thêm quỹ',
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
                }
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
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

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú / Tiêu đề',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: darkFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Quỹ',
            style: TextStyle(color: lightTextColor, fontSize: 16),
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
          'Số tiền',
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
          'Người đóng góp',
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
              hint: _isLoadingMembers
                  ? const Text(
                      "Đang tải...",
                      style: TextStyle(color: Colors.white54),
                    )
                  : const Text(
                      "Chọn người đóng góp",
                      style: TextStyle(color: Colors.white54),
                    ),
              items: _tripMembers.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: _isLoadingMembers
                  ? null
                  : (v) => setState(() => _selectedPayerUid = v),
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
          'Thời gian',
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
              'Thêm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}
