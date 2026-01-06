import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/login/login_page.dart'; // Import LoginPage

import 'firebase_options.dart'; // Import file cấu hình Firebase

void main() async {
  // Đảm bảo Flutter widgets đã được khởi tạog
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với cấu hình phù hợp cho từng nền tảng
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BTL Mobile',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Bắt đầu với LoginPage
    );
  }
}