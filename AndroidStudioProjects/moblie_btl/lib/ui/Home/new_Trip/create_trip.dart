import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblie_btl/controllers/trip_controller.dart'; // Import Controller

const primaryColor = Color(0xFF153359);
const inputFillColor = Color(0xFFF0F4F8);

class CreateTripModal extends StatefulWidget {
  const CreateTripModal({super.key});

  @override
  State<CreateTripModal> createState() => _CreateTripModalState();
}

class _CreateTripModalState extends State<CreateTripModal> {
  final _tripController = TripController(); // Sử dụng Controller
  final _titleController = TextEditingController();
  final _participantController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String selectedCurrency = 'VND';
  final List<String> currencies = ['VND', 'USD', 'EUR', 'JPY'];

  // List người tham gia: {uid, email, name, role}
  List<Map<String, dynamic>> participants = [
    // Người tạo sẽ được thêm tự động trong controller
  ];

  bool _isLoading = false;
  bool _isSearchingUser = false;

  // --- Logic UI ---

  Future<void> _addParticipantByEmail() async {
    final email = _participantController.text.trim();
    if (email.isEmpty) return;

    if (participants.any((p) => p['email'] == email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Người này đã được thêm!')));
      return;
    }

    setState(() => _isSearchingUser = true);

    // Gọi Controller để tìm user
    final user = await _tripController.findUserByEmail(email);

    if (mounted) {
      setState(() => _isSearchingUser = false);

      if (user != null) {
        setState(() {
          participants.add({
            ...user,
            'role': 'member',
          });
          _participantController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm thấy user với email: $email')));
      }
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      participants.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // --- Logic chính: TẠO CHUYẾN ĐI (Gọi Controller) ---
  Future<void> _createTrip() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên chuyến đi!')));
      return;
    }
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày!')));
      return;
    }

    // === CHECK QUAN TRỌNG: Nếu đang nhập dở email mà quên bấm nút + ===
    if (_participantController.text.trim().isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Thêm thành viên?'),
          content: Text('Bạn đang nhập dở email "${_participantController.text}". Bạn có muốn thêm người này vào không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Có, thêm ngay'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _addParticipantByEmail();
      } else {
        _participantController.clear();
      }
    }
    // =================================================================

    setState(() => _isLoading = true);

    try {
      // GỌI CONTROLLER ĐỂ TẠO TRIP
      final joinCode = await _tripController.createTrip(
        title: title,
        startDate: _startDate!,
        endDate: _endDate!,
        currency: selectedCurrency,
        participants: participants,
      );

      if (!mounted) return;

      // Hiển thị Dialog thành công
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('🎉 Trip Created!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chuyến đi đã được tạo thành công.'),
              const SizedBox(height: 20),
              const Text('Chia sẻ mã code:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: joinCode));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(joinCode, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: primaryColor)),
                      const SizedBox(width: 10),
                      const Icon(Icons.copy, size: 20, color: primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close CreateTripModal
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thêm chuyến đi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Tên chuyến đi', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _titleController,
              hintText: 'VD: Hạ Long',
              prefixIcon: const Icon(Icons.flag, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            const Text('Ngày và giờ', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelector(
                    label: 'Ngày bắt đầu',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildDateSelector(
                    label: 'Ngày kết thúc',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Giá', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            _buildCurrencyDropdown(),
            const SizedBox(height: 20),

            const Text('Thành viên', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 5),
            const Text('Thêm thành viên bằng email', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),

            _buildParticipantsList(),

            const SizedBox(height: 10),
            _buildCustomTextField(
              controller: _participantController,
              hintText: 'Nhập email',
              suffixIcon: _isSearchingUser
                  ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(
                      icon: const Icon(Icons.add_circle, color: primaryColor),
                      onPressed: _addParticipantByEmail,
                    ),
            ),
            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _createTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 5,
                ),
                child: const Text('Tạo chuyến đi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---
  Widget _buildDateSelector({required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  date != null ? _formatDate(date) : 'Chọn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: date != null ? FontWeight.bold : FontWeight.normal,
                    color: date != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: inputFillColor,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCurrency,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: primaryColor),
          items: currencies.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => selectedCurrency = newValue!),
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Column(
      children: List.generate(participants.length, (index) {
        final person = participants[index];
        final isAdmin = person['role'] == 'admin';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: isAdmin ? primaryColor.withOpacity(0.1) : inputFillColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Text(person['name'] ?? person['email'] ?? '', style: TextStyle(fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal)),
                      if (isAdmin) const Text(' (Admin)', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
              if (!isAdmin)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => _removeParticipant(index),
                ),
            ],
          ),
        );
      }),
    );
  }
}
