import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(
  0xFF2C436D,
); // Màu nền cho các trường nhập liệu
const Color lightTextColor = Colors.white;

// Dữ liệu giả định
const List<String> expenseTypes = ['Expense', 'Fund', 'Transfer'];
const List<String> tripMembers = [
  'Duy Hoang Nguyen (me)',
  'Quyen',
  'Lộc',
  'Member 4',
];

class AddExpenseModal extends StatefulWidget {
  const AddExpenseModal({super.key});

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Tiền xe',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '1.000.000',
  );

  int _selectedTypeIndex = 0; // Expense
  String? _selectedPayer = tripMembers.first;
  DateTime _selectedDate = DateTime(2025, 12, 2);

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
  }

  final TextEditingController _dateController = TextEditingController();

  String _formatDate(DateTime date) {
    return "${date.day} Dec ${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
      builder: (context, child) {
        // Đảm bảo DatePicker dùng Dark Theme
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: mainBlueColor,
              onPrimary: lightTextColor,
              surface: mainBlueColor,
              onSurface: lightTextColor,
            ),
            dialogBackgroundColor: mainBlueColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  void _saveExpense() {
    // Xử lý lưu chi tiêu
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Dùng Padding để trừ đi phần Safe Area (Status bar, notch)
    return Padding(
      // Đặt màu status bar tối để đồng bộ với Modal
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        backgroundColor: mainBlueColor, // Nền Dark Theme
        appBar: _buildCustomAppBar(context), // Header tùy chỉnh

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh Tab Expense/Fund/Transfer
              _buildTypeSegmentedControl(),
              const SizedBox(height: 25),

              // Title Input
              _buildTitleInput(),
              const SizedBox(height: 25),

              // Amount Input
              _buildAmountInput(),
              const SizedBox(height: 25),

              // Paid By và When
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPaidByDropdown()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDatePickerField(context)),
                ],
              ),
              const SizedBox(height: 25),

              // --- PLACEHOLDER CHO PARTICIPANTS/SPLIT ---
              const Text(
                'Split Details (Cần triển khai)',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 200), // Khoảng trống cuộn
            ],
          ),
        ),

        // Nút Add cố định ở dưới cùng
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            top: 10,
          ),
          child: _buildAddButton(),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: mainBlueColor, // Nền Dark
      elevation: 0,
      title: const Text(
        'Add Expense',
        style: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold),
      ),
      leading: TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTypeSegmentedControl() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: darkFieldColor, // Nền đậm
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(expenseTypes.length, (index) {
          bool isSelected = index == _selectedTypeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTypeIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : Colors.transparent, // Pill chọn là màu trắng
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  expenseTypes[index],
                  style: TextStyle(
                    color: isSelected
                        ? mainBlueColor
                        : Colors.white70, // Text pill chọn là màu xanh
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
    return TextField(
      controller: _titleController,
      style: const TextStyle(color: lightTextColor, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Title',
        labelStyle: TextStyle(color: Colors.white54),
        suffixIcon: const Icon(Icons.close, color: Colors.white54),

        // Loại bỏ đường gạch chân, dùng nền Fill
        filled: true,
        fillColor: darkFieldColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightTextColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Currency Icon Button (Nền Dark Field)
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: darkFieldColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: lightTextColor),
              const SizedBox(width: 4),
              const Text(
                '₫',
                style: TextStyle(color: lightTextColor, fontSize: 16),
              ),
              Icon(Icons.keyboard_arrow_down, color: lightTextColor, size: 20),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Amount Text Field (Nền Dark Field)
        Expanded(
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: lightTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: darkFieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: lightTextColor, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaidByDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: darkFieldColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPayer,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: lightTextColor),
          style: const TextStyle(color: lightTextColor, fontSize: 16),
          dropdownColor: darkFieldColor, // Nền Dropdown cũng là màu đậm
          items: tripMembers.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: lightTextColor),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPayer = newValue;
            });
          },
          hint: const Text('Paid By', style: TextStyle(color: Colors.white54)),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: darkFieldColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateController.text,
              style: const TextStyle(color: lightTextColor, fontSize: 16),
            ),
            Icon(Icons.keyboard_arrow_down, color: lightTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _saveExpense,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            lightTextColor, // Nút hành động cuối cùng màu trắng để nổi bật
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        'Add',
        style: TextStyle(
          color: mainBlueColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
