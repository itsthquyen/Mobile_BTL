// File: add_schedule_modal.dart (hoặc đặt chung trong trip_details.dart)
import 'package:flutter/material.dart';

// Đảm bảo định nghĩa màu chủ đạo đã được import hoặc định nghĩa lại
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class AddScheduleModal extends StatefulWidget {
  const AddScheduleModal({super.key});

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  // Các Controllers cho Form
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State quản lý ngày và giờ
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: mainBlueColor, // Màu Header của DatePicker
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: mainBlueColor, // Màu Header của TimePicker
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _saveSchedule() {
    // Xử lý lưu lịch trình ở đây
    // Ví dụ: kiểm tra _activityController.text, _selectedDate, etc.
    Navigator.pop(context); // Đóng modal sau khi lưu
  }

  @override
  Widget build(BuildContext context) {
    // Để modal chiếm gần hết màn hình, trừ phần status bar
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: screenHeight * 0.9 - topPadding,
      color: Colors.white, // Nền trắng cho Modal để tương phản
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header của Modal
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: mainBlueColor),
                    ),
                  ),
                  const Text(
                    'Add New Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: mainBlueColor, // Màu tiêu đề chính
                    ),
                  ),
                  TextButton(
                    onPressed: _saveSchedule,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: mainBlueColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    // 1. Tên Hoạt động
                    _buildInputField(
                      controller: _activityController,
                      label: 'Activity Name',
                      icon: Icons.edit,
                    ),
                    const SizedBox(height: 15),

                    // 2. Địa điểm
                    _buildInputField(
                      controller: _locationController,
                      label: 'Location (Optional)',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 15),

                    // 3. Ngày và Giờ
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimePicker(
                            controller: _dateController,
                            label: 'Date',
                            icon: Icons.calendar_today,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildDateTimePicker(
                            controller: _timeController,
                            label: 'Time',
                            icon: Icons.schedule,
                            onTap: () => _selectTime(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 4. Ghi chú
                    _buildInputField(
                      controller: _notesController,
                      label: 'Notes / Details',
                      icon: Icons.notes,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),

            // Nút Save (Cũng có thể dùng TextButton ở Header)
            // ElevatedButton(
            //   onPressed: _saveSchedule,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: mainBlueColor,
            //     minimumSize: const Size(double.infinity, 50),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   child: const Text('Save Schedule', style: TextStyle(color: Colors.white, fontSize: 16)),
            // ),
          ],
        ),
      ),
    );
  }

  // Widget chung cho các trường nhập liệu
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: mainBlueColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: mainBlueColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mainBlueColor, width: 2),
        ),
      ),
    );
  }

  // Widget chung cho Date/Time Picker
  Widget _buildDateTimePicker({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(color: mainBlueColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: mainBlueColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mainBlueColor, width: 2),
        ),
      ),
    );
  }
}
