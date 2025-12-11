import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Identify/Identify_page.dart';
import 'package:moblie_btl/ui/Notifications/Notifications_page.dart';
import 'package:moblie_btl/ui/Profile/UserProfile.dart';

import 'new_Trip/new_Trip.dart'; // Import ProfilePage

// THÊM IMPORT CHO FILE MODAL MỚI
// Lưu ý: Bạn cần thay đổi đường dẫn import này cho phù hợp với cấu trúc file thực tế của bạn
// Ví dụ: import '../home/new_trip_options.dart';

// Màu chủ đạo
const primaryColor = Color(0xFF153359);

class TripsyncPage extends StatefulWidget {
  const TripsyncPage({super.key});

  @override
  State<TripsyncPage> createState() => _TripsyncPageState();
}

class _TripsyncPageState extends State<TripsyncPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TripSyncContentPage(),
    const IdentifyPage(),
    const NotificationsPage(),
    const ProfilePage(),
  ];

  // --- HÀM MỚI: HIỂN THỊ MODAL BOTTOM SHEET ---
  void _showNewTripOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // TRẢ VỀ WIDGET MODAL VỪA TẠO
        return const NewTripOptionsModal();
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // GỌI HÀM HIỂN THỊ MODAL KHI NHẤN FAB
      _showNewTripOptionsModal();
      return;
    }
    setState(() {
      _selectedIndex = index > 2 ? index - 1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.auto_stories, 'TripSync', 0),
            _buildNavItem(Icons.qr_code_scanner, 'Identify', 1),
            const SizedBox(width: 48.0),
            _buildNavItem(Icons.notifications_none, 'Notifications', 3),
            _buildNavItem(Icons.person_outline, 'Profile', 4),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        // KHI ẤN FAB SẼ GỌI _onItemTapped(2) VÀ TỪ ĐÓ MỞ MODAL
        onPressed: () => _onItemTapped(2),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final actualIndex = index > 2 ? index - 1 : index;
    final isSelected = _selectedIndex == actualIndex;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: isSelected ? primaryColor : Colors.grey),
            Text(label, style: TextStyle(fontSize: 12, color: isSelected ? primaryColor : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// --- Màn hình Nội dung TripSync (Giữ nguyên) ---
class TripSyncContentPage extends StatelessWidget {
  const TripSyncContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(color: primaryColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TripSync', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Hi, Hoang! 👋', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildTripCard(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: index == 0 ? primaryColor : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Image.asset(
                  'assets/caravan_line_art.png',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const Text('Caravan Image Placeholder'),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: const Text('New Trip', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              'https://picsum.photos/400/200?random=1',
              fit: BoxFit.cover, height: 200, width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('City trip', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                const SizedBox(height: 4),
                const Text('This is a sample tricount', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildMemberAvatar(),
                        Transform.translate(offset: const Offset(-10, 0), child: _buildMemberAvatar()),
                        Transform.translate(offset: const Offset(-20, 0), child: _buildMemberAvatar()),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward, color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundColor: Colors.white,
      child: CircleAvatar(radius: 16, backgroundColor: Colors.grey),
    );
  }
}