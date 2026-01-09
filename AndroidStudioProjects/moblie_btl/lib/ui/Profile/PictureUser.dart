// lib/ui/Profile/PictureUser.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:moblie_btl/repository/user_repository.dart';

const Color primaryColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class EditPictureOptions extends StatefulWidget {
  final String userId;

  const EditPictureOptions({super.key, required this.userId});

  @override
  State<EditPictureOptions> createState() => _EditPictureOptionsState();
}

class _EditPictureOptionsState extends State<EditPictureOptions> {
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();

  bool _isUploading = false;
  File? _selectedImage;

  // Check if running on mobile (Android/iOS) where image_picker works
  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Pick image using image_picker (for mobile) or file_picker (for desktop)
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_isMobile) {
        // Use image_picker on mobile
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      } else {
        // Use file_picker on desktop (Windows/macOS/Linux)
        if (source == ImageSource.camera) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Camera không khả dụng trên desktop. Vui lòng chọn từ thư viện.',
                ),
              ),
            );
          }
          return;
        }

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedImage = File(result.files.single.path!);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn ảnh: $e')));
      }
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Small progress simulation if needed, but here we just go for it
      await _userRepository.uploadAvatar(
        userId: widget.userId,
        imageFile: _selectedImage!,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải lên: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Cập nhật ảnh đại diện',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (_selectedImage == null) ...[
              // Pick image options
              if (_isMobile)
                _buildOptionTile(
                  icon: Icons.camera_alt_rounded,
                  label: 'Chụp ảnh mới',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              _buildOptionTile(
                icon: Icons.photo_library_rounded,
                label: _isMobile ? 'Chọn từ thư viện' : 'Chọn file ảnh',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ] else ...[
              // Show selected image preview
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 200,
                width: 200, // Make it square for avatar feel
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accentGoldColor, width: 2),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload progress or buttons
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: null, // Indeterminate progress for upload
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          accentGoldColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Đang tải lên...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Thay đổi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _uploadAvatar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGoldColor,
                            foregroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Lưu ảnh đại diện',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 20),

            // Cancel button
            if (!_isUploading)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Hủy',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentGoldColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentGoldColor, size: 28),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
