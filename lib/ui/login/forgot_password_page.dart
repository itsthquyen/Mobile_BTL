// lib/ui/login/forgot_password_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Sử dụng cùng bảng màu từ login_page.dart
const primaryColor = Color(0xFF153359);
const inputFillColor = Color(0xFFF0F0FF);

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _message;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _errorMessage = null;
    });

    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        _message = 'Liên kết đặt lại mật khẩu đã được gửi đến email của bạn.';
      });
    } on FirebaseAuthException catch (e) {
      // Chuyển đổi mã lỗi Firebase sang tiếng Việt
      if (e.code == 'user-not-found') {
        _errorMessage = 'Không tìm thấy người dùng với email này.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Định dạng email không hợp lệ.';
      } else if (e.code == 'too-many-requests') {
        _errorMessage = 'Yêu cầu quá thường xuyên. Vui lòng thử lại sau.';
      } else {
        _errorMessage = 'Đã xảy ra lỗi: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không xác định: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          // Tính toán chiều cao để tránh lỗi tràn bộ nhớ khi hiện bàn phím
          height: size.height > 600 ? size.height - kToolbarHeight - MediaQuery.of(context).padding.top : null,
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 40), // Thay thế Spacer bằng SizedBox

              // 1. Tiêu đề
              const Text(
                'Quên mật khẩu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 2. Tin nhắn hướng dẫn
              const Text(
                'Nhập email của bạn và chúng tôi sẽ gửi một liên kết để đặt lại mật khẩu mới.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // 3. Ô nhập Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Địa chỉ Email',
                  filled: true,
                  fillColor: inputFillColor,
                  prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: primaryColor, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Hiển thị thông báo thành công
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _message!,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Hiển thị thông báo lỗi
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 20),

              // 4. Nút "Gửi yêu cầu"
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendPasswordResetEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Gửi yêu cầu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Thay thế Spacer bằng SizedBox
            ],
          ),
        ),
      ),
    );
  }
}