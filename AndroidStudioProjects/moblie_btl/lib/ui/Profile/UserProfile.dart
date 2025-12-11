import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Profile/PictureUser.dart';

// Import file edit_picture_options.dart (giả định nằm trong cùng thư mục)


// Màu chủ đạo đã được định nghĩa ở các file khác
const primaryColor = Color(0xFF153359);

// Dữ liệu giả (Mock Data) để hiển thị trên giao diện
// Sau này bạn sẽ thay thế bằng dữ liệu lấy từ Firebase Auth và Firestore.
class MockUserProfile {
  final String username = 'Nguyễn Văn A';
  final String email = 'NVA@gmail.com';
  final String phoneNumber = '0399999999';
  const MockUserProfile();
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Hàm xử lý Log Out (Placeholder)
  void _handleLogout(BuildContext context) {
    // TODO: Triển khai logic đăng xuất Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging out...')),
    );
  }

  // --- HÀM MỚI: HIỂN THỊ MODAL EDIT PICTURE ---
  void _showEditPictureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext sheetContext) {
        // Điều hướng đến widget chuyên biệt EditPictureOptions
        return const EditPictureOptions();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const MockUserProfile user = MockUserProfile();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // 1. Header Card (Phần màu xanh đậm)
            // Truyền user và context cho Header Card
            _buildHeaderCard(context, user),

            // 2. Danh sách Thông tin Cá nhân (Giữ nguyên)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  _ProfileInfoCard(
                    icon: Icons.person_outline,
                    label: 'Username',
                    value: user.username,
                  ),
                  const SizedBox(height: 15),
                  _ProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 15),
                  _ProfileInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone number',
                    value: user.phoneNumber,
                  ),
                  const SizedBox(height: 40),

                  // 3. Nút Log Out (Giữ nguyên)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CẬP NHẬT HÀM NÀY ĐỂ GÁN SỰ KIỆN onTap CHO NÚT BÚT CHÌ
  Widget _buildHeaderCard(BuildContext context, MockUserProfile user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title và Greeting (Giữ nguyên)
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Hi, ${user.username}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),

          // Avatar và Tên
          Center(
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: const AssetImage('assets/default_avatar.png'),
                        child: user.username.isEmpty ? const Icon(Icons.person, size: 50, color: primaryColor) : null,
                      ),
                    ),
                    // Nút chỉnh sửa
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell( // SỬ DỤNG InkWell ĐỂ BẮT SỰ KIỆN ONTAP
                        onTap: () => _showEditPictureOptions(context), // GỌI HÀM HIỂN THỊ MODAL
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: primaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Tên người dùng
                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// --- Widget Dành riêng: Profile Info Card (Giữ nguyên) ---

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          children: [
            // Icon
            Icon(icon, color: primaryColor),
            const SizedBox(width: 15),

            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Spacer(),

            // Value
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}