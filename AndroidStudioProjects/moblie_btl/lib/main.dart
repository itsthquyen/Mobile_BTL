import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/login/login_page.dart'; // Import LoginPage

void main() async {
  // Đảm bảo Flutter widgets đã được khởi tạog
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Firebase Login Demo',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Bắt đầu với LoginPage
    );
  }
}