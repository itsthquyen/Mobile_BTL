// lib/ui/home/new_trip_options.dart

import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Home/new_Trip/create_trip.dart';

import 'join_trip.dart';

const primaryColor = Color(0xFF153359);

class NewTripOptionsModal extends StatelessWidget {
  const NewTripOptionsModal({super.key});

  // Hàm xử lý khi chọn 'Start a new trip'
  void _startNewTrip(BuildContext context) {
    Navigator.pop(context); // Đóng Modal
    // TODO: Điều hướng đến màn hình tạo chuyến đi mới (NewTripPage)
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateTrip()),
    );
  }

  // Hàm xử lý khi chọn 'Join an existing trip'
  void _joinExistingTrip(BuildContext context) {
    Navigator.pop(context); // Đóng Modal
    // TODO: Mở hộp thoại nhập mã mời hoặc liên kết
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const JoinTripPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tiêu đề "Add"
                const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                // Nút "X" (Đóng)
                IconButton(
                  icon: const Icon(Icons.close, size: 30, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 1. Tùy chọn Start a new trip
            _buildOptionCard(
              context: context,
              icon: Icons.add_circle_outline,
              title: 'Start a new trip',
              subtitle: 'Start a new tricount from scratch.',
              onTap: () => _startNewTrip(context),
            ),
            const SizedBox(height: 15),

            // 2. Tùy chọn Join an existing trip
            _buildOptionCard(
              context: context,
              icon: Icons.link,
              title: 'Join an existing trip',
              subtitle: 'Use an invite link to join an existing trip.',
              onTap: () => _joinExistingTrip(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget riêng cho từng Card tùy chọn
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              // Icon
              Icon(icon, color: primaryColor, size: 30),
              const SizedBox(width: 15),

              // Title và Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}