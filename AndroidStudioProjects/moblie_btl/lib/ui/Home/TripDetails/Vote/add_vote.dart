// lib/ui/Home/TripDetails/Vote/add_vote.dart
import 'package:flutter/material.dart';


const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;

class AddVoteLocationModal extends StatefulWidget {
  const AddVoteLocationModal({super.key});

  @override
  State<AddVoteLocationModal> createState() => _AddVoteLocationModalState();
}

class _AddVoteLocationModalState extends State<AddVoteLocationModal> {
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key để validate form

  @override
  void dispose() {
    _locationNameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveLocation() {
    // Kiểm tra xem form có hợp lệ không
    if (_formKey.currentState!.validate()) {
      // Nếu hợp lệ, xử lý lưu dữ liệu
      print('Location Name: ${_locationNameController.text}');
      print('Description: ${_descriptionController.text}');
      print('Image URL: ${_imageUrlController.text}');

      // Đóng modal sau khi lưu
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding để modal không bị che bởi status bar
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        backgroundColor: mainBlueColor,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. Header của modal
              _buildCustomHeader(context),
              // 2. Nội dung form, cho phép cuộn
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _locationNameController,
                        label: 'Location Name',
                        hint: 'e.g., Tokyo Skytree',
                        icon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location name.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(
                        controller: _imageUrlController,
                        label: 'Image URL (Optional)',
                        hint: 'https://...',
                        icon: Icons.image_outlined,
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'A few words about this place...',
                        icon: Icons.description_outlined,
                        maxLines: 4, // Cho phép nhập nhiều dòng
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 3. Nút Add cố định ở dưới
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            left: 20,
            right: 20,
            top: 10,
          ),
          child: _buildAddButton(),
        ),
      ),
    );
  }

  // Widget cho header
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: lightTextColor, fontSize: 16)),
          ),
          const Text(
            'Add Vote Location',
            style: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          // Giữ khoảng trống cân bằng
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  // Widget tái sử dụng cho các trường nhập liệu
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: lightTextColor, fontSize: 16),
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: darkFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            // Hiển thị viền đỏ khi có lỗi validate
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Widget cho nút Add
  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _saveLocation,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: mainBlueColor,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Add Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
