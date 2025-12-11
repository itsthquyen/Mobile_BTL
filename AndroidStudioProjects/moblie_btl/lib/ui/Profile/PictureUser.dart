// lib/ui/profile/edit_picture_options.dart

import 'package:flutter/material.dart';
// Cần package image_picker (giả định đã cài đặt)
// import 'package:image_picker/image_picker.dart';

// Giả định ImageSource được định nghĩa từ package image_picker (chỉ để code biên dịch)
enum ImageSource { camera, gallery }
const primaryColor = Color(0xFF153359);

class EditPictureOptions extends StatelessWidget {
  const EditPictureOptions({super.key});

  // Hàm Placeholder cho logic chọn ảnh và upload
  void _pickImage(BuildContext context, ImageSource source) {
    // TODO: Triển khai logic chọn ảnh, upload lên Firebase Storage và cập nhật Firestore/Provider

    String sourceName = source == ImageSource.camera ? 'Camera' : 'Thư viện';

    // Đóng màn hình/dialog hiện tại
    Navigator.pop(context);

    // Thông báo tạm thời
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chọn $sourceName. Bắt đầu upload...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Column và Padding để mô phỏng giao diện Bottom Sheet
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Nút "Edit Profile Picture" (Tiêu đề)
          ListTile(
            title: const Text(
              'Edit Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {},
          ),
          const Divider(height: 1),

          // Nút "Take Photo"
          ListTile(
            title: const Text('Take Photo', textAlign: TextAlign.center),
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
          const Divider(height: 1),

          // Nút "Choose from Library"
          ListTile(
            title: const Text('Choose from Library', textAlign: TextAlign.center),
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),
          const Divider(height: 1),

          // Nút "Cancel"
          ListTile(
            title: const Text(
              'Cancel',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            onTap: () => Navigator.pop(context), // Đóng màn hình
          ),
        ],
      ),
    );
  }
}