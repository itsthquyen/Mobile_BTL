// lib/ui/trip/new_trip_page.dart

import 'package:flutter/material.dart';

// Màu chủ đạo
const primaryColor = Color(0xFF153359);
const inputFillColor = Color(0xFFF0F0FF); // Màu nền input đồng bộ

class CreateTrip extends StatefulWidget {
  const CreateTrip({super.key});

  @override
  State<CreateTrip> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<CreateTrip> {
  // Controllers cho các trường input
  final TextEditingController _titleController = TextEditingController(text: 'Ha long bay');
  final TextEditingController _participantController = TextEditingController();

  // Dữ liệu giả cho danh sách tham gia
  List<String> participants = ['Duy Hoang Nguyen (Me)', 'Quyen', 'Loc'];

  // Giá trị tiền tệ giả định
  String selectedCurrency = 'Vietnamese Dong';
  final List<String> currencies = ['Vietnamese Dong', 'USD', 'EUR'];

  @override
  void dispose() {
    _titleController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  void _addParticipant() {
    final name = _participantController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        participants.add(name);
        _participantController.clear();
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      participants.removeAt(index);
    });
  }

  void _createTrip() {
    // TODO: Triển khai logic lưu dữ liệu vào Firestore
    debugPrint('Creating trip: ${_titleController.text}');
    // Đóng màn hình
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chuyến đi đã được tạo thành công!')),
    );
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
        title: const Text('Add tricount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // TODO: Điều hướng đến màn hình thông báo
            },
          ),
        ],
        // Dùng FlexibleSpaceBar để tạo phần Location
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: primaryColor),
          padding: const EdgeInsets.only(top: 55, left: 15),
          child: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 20),
              SizedBox(width: 5),
              Text('Ha Long Bay, Vietnam', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. Title Input ---
            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            _buildCustomTextField(
              controller: _titleController,
              hintText: 'Trip Title',
              prefixIcon: const Text('🚩 ', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),

            // --- 2. Currency Dropdown ---
            const Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 8),
            _buildCurrencyDropdown(),
            const SizedBox(height: 20),

            // --- 3. Participants ---
            const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
            const SizedBox(height: 10),

            // Danh sách Participants hiện tại
            _buildParticipantsList(),

            // Input để thêm Participants mới
            const SizedBox(height: 10),
            _buildCustomTextField(
              controller: _participantController,
              hintText: 'Participant Name',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: primaryColor),
                onPressed: _addParticipant,
              ),
            ),
            const SizedBox(height: 20),

            // --- 4. Add Another Participant Button ---
            TextButton.icon(
              onPressed: _addParticipant,
              icon: const Icon(Icons.person_add, color: primaryColor),
              label: const Text('Add Another Participant', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 50),

            // --- 5. Create Trip Button ---
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
                child: const Text('Create trip', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widget Build Functions ---

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
        prefixIcon: prefixIcon != null ? Padding(padding: const EdgeInsets.only(left: 15.0), child: prefixIcon) : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: primaryColor, width: 2.0)),
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
          style: const TextStyle(color: Colors.black, fontSize: 16),
          dropdownColor: Colors.white,
          items: currencies.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCurrency = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(participants.length, (index) {
        final name = participants[index];
        final isMe = name.contains('(Me)');

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: inputFillColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(name, style: const TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              if (isMe)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Me', style: TextStyle(color: Colors.white, fontSize: 12)),
                )
              else
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => _removeParticipant(index),
                ),
            ],
          ),
        );
      }),
    );
  }
}