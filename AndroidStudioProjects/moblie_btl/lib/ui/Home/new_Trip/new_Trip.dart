// lib/ui/home/new_trip_options.dart

import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Home/new_Trip/create_trip.dart';
import 'join_trip.dart';

const primaryColor = Color(0xFF153359);

class NewTripOptionsModal extends StatelessWidget {
  const NewTripOptionsModal({super.key});

  // ===== TẠO CHUYẾN ĐI MỚI =====
  void _startNewTrip(BuildContext context) {
    Navigator.pop(context); // Đóng modal
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateTripModal()),
    );
  }

  // ===== THAM GIA CHUYẾN ĐI =====
  void _joinExistingTrip(BuildContext context) {
    Navigator.pop(context); // Đóng modal
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const JoinTripModal()),
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
            // ===== TIÊU ĐỀ =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thêm chuyến đi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 30, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== TẠO CHUYẾN ĐI MỚI =====
            _buildOptionCard(
              icon: Icons.add_circle_outline,
              title: 'Tạo chuyến đi mới',
              subtitle: 'Bắt đầu một chuyến đi mới từ đầu.',
              onTap: () => _startNewTrip(context),
            ),

            const SizedBox(height: 15),

            // ===== THAM GIA CHUYẾN ĐI =====
            _buildOptionCard(
              icon: Icons.link,
              title: 'Tham gia chuyến đi',
              subtitle: 'Nhập mã mời hoặc liên kết để tham gia.',
              onTap: () => _joinExistingTrip(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ===== CARD TÙY CHỌN =====
  Widget _buildOptionCard({
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
              Icon(icon, color: primaryColor, size: 30),
              const SizedBox(width: 15),

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

              const Icon(Icons.chevron_right,
                  color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
