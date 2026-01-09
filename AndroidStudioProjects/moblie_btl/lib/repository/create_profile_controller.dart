// controllers/create_profile_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class CreateProfileController {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Danh sách các ảnh có sẵn trong assets
  // Lưu ý: Bạn phải đảm bảo các file này đã có trong thư mục assets và khai báo trong pubspec.yaml
  final List<String> assetAvatars = [
    'assets/images/anh1.jpg',
    'assets/images/avatar_2.jpg',
    'assets/images/avatar_3.jpg',
    'assets/images/avatar_4.jpg',
    'assets/images/avatar_5.jpg',
    'assets/images/avatar_6.jpg',
  ];

  User? get currentUser => _auth.currentUser;

  // 2. Cập nhật hàm lưu để nhận avatarUrl từ UI
  Future<String?> handleSaveProfile({
    required String name,
    required String phone,
    required String selectedAvatar, // Thêm tham số này
  }) async {
    if (currentUser == null) return "User not logged in";
    if (name.isEmpty) return "Vui lòng nhập tên hiển thị của bạn.";
    if (selectedAvatar.isEmpty) return "Vui lòng chọn ảnh đại diện.";

    try {
      final userModel = UserModel(
        uid: currentUser!.uid,
        displayName: name,
        email: currentUser!.email ?? '',
        phone: phone,
        avatarUrl: selectedAvatar,
        fcmToken: '',
      );

      await _userService.saveProfile(userModel);
      return null; // Trả về null nếu thành công
    } catch (e) {
      return e.toString();
    }
  }
}
