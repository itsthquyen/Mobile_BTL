// lib/ui/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moblie_btl/ui/Home/TripSync_Page.dart';
import 'package:moblie_btl/ui/onboarding/onboarding_page.dart';

import 'forgot_password_page.dart';
import 'signup_page.dart';

// --- CÁC HẰNG SỐ MÀU ---
const primaryColor = Color(0xFF153359);
const inputFillColor = Color(0xFFF0F0FF);

// --- WIDGET NÚT ĐĂNG NHẬP MẠNG XÃ HỘI ---
class _SocialLoginButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final Color primaryColor;

  const _SocialLoginButton({
    required this.icon,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          icon,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// --- TRANG ĐĂNG NHẬP CHÍNH ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- HÀM KIỂM TRA NGƯỜI DÙNG MỚI ---
  Future<bool> _checkIfNewUser(User user) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return !doc.exists; // Nếu document KHÔNG tồn tại => là người dùng mới
    } catch (e) {
      // Nếu có lỗi, coi như là người dùng cũ để tránh bị kẹt
      return false;
    }
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP ---
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      final user = credential.user;
      if (user == null || !mounted) return;
      
      
      // KIỂM TRA NGƯỜI DÙNG MỚI HAY CŨ
      final isNew = await _checkIfNewUser(user);
      
      if (!mounted) return;

      if (isNew) {
        // Chuyển đến Onboarding nếu là người dùng mới
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingPage()), 
        );
      } else {
        // Chuyển đến Trang chủ nếu là người dùng cũ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TripsyncPage()),
        );
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        _errorMessage = 'Sai email hoặc mật khẩu.';
      } else if (e.code == 'user-disabled') {
        _errorMessage = 'Tài khoản này đã bị khóa.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Định dạng email không hợp lệ.';
      } else {
        _errorMessage = 'Lỗi đăng nhập: ${e.message}';
      }
    } catch (e) {
      _errorMessage = 'Đã có lỗi xảy ra: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- PHƯƠNG THỨC BUILD GIAO DIỆN ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height > 800 ? size.height : null,
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 80), // Thay thế Spacer bằng SizedBox để tránh lỗi layout

              Text(
                'Đăng nhập', // Sửa: Login here -> Đăng nhập
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Chào mừng bạn đã quay trở lại!', // Sửa Welcome message
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),

              // Input Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: inputFillColor,
                  prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
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

              // Input Mật khẩu
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  filled: true,
                  fillColor: inputFillColor,
                  prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),

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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                  },
                  child: const Text(
                    'Quên mật khẩu?', // Sửa: Forgot your password? -> Quên mật khẩu?
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút Đăng nhập
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Đăng nhập', // Sửa: Sign in -> Đăng nhập
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Nút Tạo tài khoản mới
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpPage()));
                },
                child: const Text(
                  'Tạo tài khoản mới', // Sửa: Create new account -> Tạo tài khoản mới
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'Hoặc tiếp tục với', // Sửa: Or continue with
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Các nút đăng nhập mạng xã hội
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _SocialLoginButton(icon: 'G', onTap: () {}, primaryColor: primaryColor),
                  const SizedBox(width: 20),
                  _SocialLoginButton(icon: 'f', onTap: () {}, primaryColor: primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
