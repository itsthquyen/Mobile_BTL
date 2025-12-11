// lib/ui/identify/identify_page.dart

import 'package:flutter/material.dart';

// Màu chủ đạo
const primaryColor = Color(0xFF153359);

// Màn hình Identify
class IdentifyPage extends StatelessWidget {
  const IdentifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả cho danh sách tài liệu
    final List<Map<String, dynamic>> documents = [
      {'icon': Icons.public, 'label': 'Passport', 'onTap': () => debugPrint('Open Passport')},
      {'icon': Icons.credit_card, 'label': 'ID Card', 'onTap': () => debugPrint('Open ID Card')},
      {'icon': Icons.badge, 'label': 'Driver License', 'onTap': () => debugPrint('Open Driver License')},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 1. Header Card (Phần màu xanh đậm)
          _buildHeader(context),

          // 2. Danh sách Tài liệu
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: _DocumentCard(
                    icon: doc['icon'] as IconData,
                    label: doc['label'] as String,
                    onTap: doc['onTap'] as Function(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Lấy tên người dùng giả định
    const String username = 'Hoang';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              const Text(
                'My Documents',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Avatar Placeholder
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  // TODO: Thay bằng ảnh avatar thật
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Greeting
          const Text(
            'Hi, Hoang! 👋',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget Dành riêng: Document Card ---

class _DocumentCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function() onTap;

  const _DocumentCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1), // Nền icon nhẹ nhàng
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: primaryColor, size: 30),
              ),
              const SizedBox(width: 20),

              // Label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Arrow
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}