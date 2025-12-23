import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Profile/PictureUser.dart';
import '../login/login_page.dart';
import 'User.dart';

const primaryColor = Color(0xFF153359);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// ===== LOAD USER =====
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        userProfile = UserProfile.fromFirestore(doc.id, doc.data()!);
        isLoading = false;
      });
    }
  }

  /// ===== UPDATE PROFILE =====
  Future<void> _updateProfile(String name, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không được để trống thông tin')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'displayName': name,
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      userProfile = UserProfile(
        uid: userProfile!.uid,
        displayName: name,
        email: userProfile!.email,
        phone: phone,
        avatarUrl: userProfile!.avatarUrl,
      );
    });

    _showSuccessDialog();
  }

  /// ===== SUCCESS DIALOG (GIỮA MÀN HÌNH) =====
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle,
                    color: Colors.green, size: 70),
                SizedBox(height: 15),
                Text(
                  'Cập nhật thành công!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  /// ===== EDIT PROFILE =====
  void _showEditProfileDialog() {
    final nameController =
    TextEditingController(text: userProfile!.displayName);
    final phoneController =
    TextEditingController(text: userProfile!.phone);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // đóng dialog chỉnh sửa trước
              await _updateProfile(
                nameController.text.trim(),
                phoneController.text.trim(),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// ===== LOGOUT =====
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  /// ===== EDIT AVATAR =====
  void _showEditPictureOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const EditPictureOptions(),
    );
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _ProfileInfoCard(
                    icon: Icons.person_outline,
                    label: 'Username',
                    value: userProfile!.displayName,
                  ),
                  const SizedBox(height: 15),
                  _ProfileInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: userProfile!.email,
                  ),
                  const SizedBox(height: 15),
                  _ProfileInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: userProfile!.phone,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style:
                        TextStyle(fontSize: 20, color: Colors.white),
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

  Widget _buildHeader() {
    return Container(
      padding:
      const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: userProfile!.avatarUrl.isNotEmpty
                      ? NetworkImage(userProfile!.avatarUrl)
                      : const AssetImage('assets/default_avatar.png')
                  as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _showEditPictureOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                      Border.all(color: primaryColor, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userProfile!.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= INFO CARD =================
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
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 15),
            Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
