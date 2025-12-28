// views/create_profile_page.dart
import 'package:flutter/material.dart';
import '../../controllers/create_profile_controller.dart';
import '../Home/TripSync_Page.dart';

const primaryColor = Color(0xFF153359);

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _controller = CreateProfileController(); // Khởi tạo Controller
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Biến lưu ảnh đang chọn (default là ảnh đầu tiên hoặc rỗng)
  String _selectedAvatar = ''; 

  @override
  void initState() {
    super.initState();
    _emailController.text = _controller.currentUser?.email ?? '';
    // Mặc định chọn ảnh đầu tiên nếu danh sách không rỗng
    if (_controller.assetAvatars.isNotEmpty) {
      _selectedAvatar = _controller.assetAvatars[0];
    }
  }

  // Hàm hiển thị BottomSheet để chọn ảnh
  void _showAvatarSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: primaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            children: [
              const Text(
                'Chọn ảnh đại diện',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _controller.assetAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarPath = _controller.assetAvatars[index];
                    final isSelected = _selectedAvatar == avatarPath;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatarPath;
                        });
                        Navigator.pop(context); // Đóng BottomSheet sau khi chọn
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.amber, width: 3) : null,
                        ),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(avatarPath),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSave() async {
    setState(() => _isLoading = true);

    final error = await _controller.handleSaveProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      selectedAvatar: _selectedAvatar, // Truyền ảnh đã chọn xuống Controller
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TripsyncPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              _buildAvatarSection(),
              const SizedBox(height: 40),
              _buildTextField(_nameController, 'Tên hiển thị', Colors.grey[200]!),
              const SizedBox(height: 16),
              _buildTextField(_emailController, 'Email', Colors.grey[350]!, isReadOnly: true),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Số điện thoại (tùy chọn)', Colors.grey[200]!, keyboardType: TextInputType.phone),
              const Spacer(flex: 3),
              _buildSubmitButton(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: const Color(0xFFE0E0E0),
            // Hiển thị ảnh assets đã chọn
            backgroundImage: _selectedAvatar.isNotEmpty ? AssetImage(_selectedAvatar) : null,
            child: _selectedAvatar.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showAvatarSelection, // Mở danh sách chọn ảnh
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, size: 20, color: primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color color, {bool isReadOnly = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: color,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _onSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A1A2E),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Hoàn tất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
