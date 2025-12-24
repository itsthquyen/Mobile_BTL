// lib/ui/trip/new_trip_page.dart

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để copy join code

// Màu chủ đạo
const primaryColor = Color(0xFF153359);
const inputFillColor = Color(0xFFF0F0FF);

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  State<CreateTrip> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<CreateTrip> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _participantController = TextEditingController();

  // State
  List<Map<String, dynamic>> participants = [];

  String selectedCurrency = 'VND';
  final List<String> currencies = ['VND', 'USD', 'EUR'];

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isSearchingUser = false;

  @override
  void initState() {
    super.initState();
    _setupCurrentUser();
  }

  void _setupCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        participants.add({
          'uid': user.uid,
          'name': user.displayName ?? user.email ?? 'Me',
          'email': user.email ?? '',
          'role': 'admin',
        });
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  // --- LOGIC MỚI: TÌM VÀ THÊM THÀNH VIÊN BẰNG EMAIL ---
  // Trả về true nếu thêm thành công, false nếu thất bại/đã tồn tại/lỗi
  Future<bool> _addParticipantByEmail() async {
    final emailInput = _participantController.text.trim();
    if (emailInput.isEmpty) return false;

    // 1. Kiểm tra xem đã tồn tại trong danh sách chưa
    final exists = participants.any((p) => p['email'] == emailInput);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User này đã được thêm!')));
      _participantController.clear();
      return true; // Coi như thành công vì đã có trong list
    }

    setState(() => _isSearchingUser = true);

    try {
      // 2. Query tìm user trong collection 'users'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailInput)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();

        // 3. Thêm user tìm thấy vào danh sách state
        setState(() {
          participants.add({
            'uid': userDoc.id,
            'name': userData['displayName'] ?? emailInput,
            'email': emailInput,
            'role': 'member',
          });
          _participantController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm thành viên thành công!')));
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Không tìm thấy user có email "$emailInput"'),
          backgroundColor: Colors.redAccent,
        ));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi tìm kiếm: $e')));
      return false;
    } finally {
      if(mounted) setState(() => _isSearchingUser = false);
    }
  }

  void _removeParticipant(int index) {
    if (participants[index]['role'] == 'admin') return;
    setState(() {
      participants.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
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

  String _generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    String code = String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    return code;
  }

  String _getRandomCoverUrl() {
    final List<String> covers = [
      'https://picsum.photos/id/1015/400/200',
      'https://picsum.photos/id/1036/400/200',
      'https://picsum.photos/id/1047/400/200',
      'https://picsum.photos/id/1050/400/200',
      'https://picsum.photos/id/164/400/200',
      'https://picsum.photos/id/28/400/200',
    ];
    return covers[Random().nextInt(covers.length)];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // --- Logic chính: TẠO CHUYẾN ĐI ---
  Future<void> _createTrip() async {
    final title = _titleController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập!')));
      return;
    }
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
        // Thử thêm thành viên
        final success = await _addParticipantByEmail();
        // Nếu thêm thất bại (không tìm thấy user), dừng lại để người dùng kiểm tra
        if (!success) return;
      } else {
        // Nếu chọn Không, xóa text đi để tiếp tục
        _participantController.clear();
      }
    }
    // =================================================================

    setState(() => _isLoading = true);

    try {
      final joinCode = _generateJoinCode();
      final coverUrl = _getRandomCoverUrl();

      Map<String, dynamic> membersMap = {};

      for (var p in participants) {
        final uid = p['uid'] as String?;
        final role = p['role'] as String?;

        if (uid != null && uid.isNotEmpty && role != null) {
          membersMap[uid] = role;
        }
      }

      if (!membersMap.containsKey(user.uid)) {
        membersMap[user.uid] = 'admin';
      }

      await FirebaseFirestore.instance.collection('trips').add({
        'name': title,
        'coverUrl': coverUrl,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'createdBy': user.email ?? user.uid,
        'totalBudget': 0,
        'fundTotal': 0,
        'joinCode': joinCode,
        'members': membersMap,
        'currency': selectedCurrency,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

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
                Navigator.pop(ctx);
                Navigator.pop(context);
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
                      onPressed: () => _addParticipantByEmail(),
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
