import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moblie_btl/services/notification_service.dart';

// --- MÀU SẮC ĐỒNG BỘ VỚI ADD_EXPENSE ---
const primaryColor = Color(0xFF153359);
const darkFieldColor = Color(0xFF2C436D);
const lightTextColor = Colors.white;

class AddScheduleModal extends StatefulWidget {
  final String tripId;
  // Dữ liệu cho chế độ chỉnh sửa (có thể null)
  final Map<String, dynamic>? scheduleData;
  final String? scheduleId;

  const AddScheduleModal({
    super.key,
    required this.tripId,
    this.scheduleData,
    this.scheduleId,
  });

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  DateTime? _startTime;
  DateTime? _endTime;
  bool _isLoading = false;
  String? _tripName; // Để lưu tên trip cho notification

  bool get _isEditing => widget.scheduleId != null;

  @override
  void initState() {
    super.initState();
    _loadTripName();
    // Nếu là chế độ chỉnh sửa, điền sẵn thông tin
    if (_isEditing && widget.scheduleData != null) {
      final data = widget.scheduleData!;
      _titleController.text = data['title'] ?? '';
      _locationController.text = data['locationName'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      if (data['startTime'] is Timestamp) {
        _startTime = (data['startTime'] as Timestamp).toDate();
      }
      if (data['endTime'] is Timestamp) {
        _endTime = (data['endTime'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _loadTripName() async {
    final tripDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();
    if (tripDoc.exists && mounted) {
      setState(() {
        _tripName = tripDoc.data()?['name'] ?? 'Chuyến đi';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              onPrimary: lightTextColor,
              surface: darkFieldColor,
              onSurface: lightTextColor,
            ),
            dialogBackgroundColor: primaryColor,
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              onPrimary: lightTextColor,
              surface: darkFieldColor,
              onSurface: lightTextColor,
            ),
            dialogBackgroundColor: primaryColor,
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = dateTime;
        if (_endTime != null && _endTime!.isBefore(_startTime!)) {
          _endTime = null;
        }
      } else {
        _endTime = dateTime;
      }
    });
  }

  // --- HÀM LƯU HOẶC CẬP NHẬT LỊCH TRÌNH ---
  Future<void> _saveOrUpdateSchedule() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề và chọn thời gian đầy đủ.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final schedulePayload = {
        'title': title,
        'locationName': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'startTime': Timestamp.fromDate(_startTime!),
        'endTime': Timestamp.fromDate(_endTime!),
        'updatedAt': FieldValue.serverTimestamp(), // Thêm trường update
      };

      final itineraryRef = FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .collection('itinerary');

      if (_isEditing) {
        // Chế độ chỉnh sửa: UPDATE
        await itineraryRef.doc(widget.scheduleId).update(schedulePayload);
        // Gửi thông báo cập nhật cho các thành viên
        try {
          print('🚀 Calling notifyScheduleUpdated...');
          await _notificationService.notifyScheduleUpdated(
            tripId: widget.tripId,
            tripName: _tripName ?? 'Chuyến đi',
            scheduleName: title,
          );
          print('✅ notifyScheduleUpdated completed');
        } catch (e, stackTrace) {
          print('❌ Error in notifyScheduleUpdated: $e');
          print('StackTrace: $stackTrace');
        }
      } else {
        // Chế độ thêm mới: ADD
        schedulePayload['createdAt'] = FieldValue.serverTimestamp();
        schedulePayload['type'] = 'activity';
        schedulePayload['status'] = 'planned';
        await itineraryRef.add(schedulePayload);
        // Gửi thông báo thêm mới cho các thành viên
        try {
          print('🚀 Calling notifyScheduleAdded...');
          await _notificationService.notifyScheduleAdded(
            tripId: widget.tripId,
            tripName: _tripName ?? 'Chuyến đi',
            scheduleName: title,
          );
          print('✅ notifyScheduleAdded completed');
        } catch (e, stackTrace) {
          print('❌ Error in notifyScheduleAdded: $e');
          print('StackTrace: $stackTrace');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Đã cập nhật lịch trình!'
                  : 'Đã thêm lịch trình thành công!',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year.toString().substring(2)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                Text(
                  _isEditing ? 'Chỉnh sửa lịch trình' : 'Thêm lịch trình',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: lightTextColor,
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
            const SizedBox(height: 16),

            _buildCustomTextField(
              controller: _titleController,
              hintText: 'Tiêu đề *',
              prefixIcon: const Icon(Icons.title, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _locationController,
              hintText: 'Địa điểm',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _descriptionController,
              hintText: 'Mô tả',
              prefixIcon: const Icon(
                Icons.description_outlined,
                color: Colors.white70,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    label: 'Bắt đầu *',
                    time: _startTime,
                    onTap: () => _pickDateTime(true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(
                    label: 'Kết thúc *',
                    time: _endTime,
                    onTap: () => _pickDateTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveOrUpdateSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightTextColor,
                  foregroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: primaryColor)
                    : Text(
                        _isEditing ? 'Lưu thay đổi' : 'Thêm lịch trình',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    Widget? prefixIcon,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: lightTextColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: darkFieldColor,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime? time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: darkFieldColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: lightTextColor),
                const SizedBox(width: 8),
                Text(
                  time != null ? _formatDateTime(time) : 'Chọn giờ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: time != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: time != null ? lightTextColor : Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
