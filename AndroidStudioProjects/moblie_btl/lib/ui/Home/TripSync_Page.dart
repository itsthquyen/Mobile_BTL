import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Identify/Identify_page.dart';
import 'package:moblie_btl/ui/Notifications/Notifications_page.dart';
import 'package:moblie_btl/ui/Profile/UserProfile.dart';

// Đảm bảo các import này hoạt động. Tôi sẽ giữ nguyên chúng.
import 'package:moblie_btl/ui/Home/TripDetails/trip_details.dart';
import 'package:moblie_btl/ui/Home/new_Trip/new_Trip.dart';

// Màu chủ đạo
const primaryColor = Color(0xFF153359);

// Lớp Trip đã được xóa khỏi đây vì nó được import từ trip_details.dart

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

  // --- HÀM: HIỂN THỊ MODAL BOTTOM SHEET ---
  void _showNewTripOptionsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // Tên NewTripOptionsModal giả định là đúng
        return const NewTripOptionsModal();
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 2) {
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

// **********************************************
// ************ TRIPSYNC CONTENT PAGE ***********
// **********************************************

class TripSyncContentPage extends StatelessWidget {
  const TripSyncContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Định nghĩa chuyến đi hiện tại
    final currentTrip = Trip(
      title: 'Ha Long Bay',
      subtitle: 'This is a sample tricount',
      imageUrl: 'https://picsum.photos/400/200?random=1',
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
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
                  backgroundImage: const NetworkImage('https://picsum.photos/50/50?random=2'),
                ),
              ],
            ),
          ),

          // Current Trip Card (Bắt sự kiện nhấn)
          Transform.translate(
            offset: const Offset(0, -60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildTripCard(
                context: context,
                trip: currentTrip,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pager Indicator
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

                // Tiêu đề cho My Trips
                const Text(
                  'My Trips',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 15),

                // Danh sách My Trips (ListView ngang)
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // *** ĐÃ THÊM TRUYỀN context ***
                      _buildMiniTripCard(
                        context: context,
                        title: 'Japan 2024',
                        date: '12-19 Dec',
                        memberCount: 4,
                        imageColor: Colors.teal,
                      ),
                      const SizedBox(width: 15),
                      _buildMiniTripCard(
                        context: context,
                        title: 'Da Lat Weekend',
                        date: '05-07 Nov',
                        memberCount: 2,
                        imageColor: Colors.deepOrange,
                      ),
                      const SizedBox(width: 15),
                      _buildMiniTripCard(
                        context: context,
                        title: 'Singapore',
                        date: '30-05 May',
                        memberCount: 5,
                        imageColor: Colors.purple,
                      ),
                      const SizedBox(width: 15),
                    ],
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

  // --- Widget Card Chuyến Đi Lớn (Current Trip) ---
  Widget _buildTripCard({required BuildContext context, required Trip trip}) {
    // Tên TripDetailsPage giả định là đúng
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell( // BẮT SỰ KIỆN NHẤN ĐỂ ĐIỀU HƯỚNG
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => TripDetailsPage(trip: trip),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                trip.imageUrl,
                fit: BoxFit.cover, height: 200, width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 4),
                  Text(trip.subtitle, style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
      ),
    );
  }

  // --- Widget Card Chuyến Đi Nhỏ cho My Trips ---
  Widget _buildMiniTripCard({
    required BuildContext context, // *** ĐÃ THÊM CONTEXT ĐỂ ĐIỀU HƯỚNG ***
    required String title,
    required String date,
    required int memberCount,
    required Color imageColor,
  }) {
    // *** TẠO TRIP MODEL TẠM THỜI CHO THẺ NHỎ ***
    final miniTrip = Trip(
      title: title,
      subtitle: '$date - $memberCount members',
      imageUrl: 'https://picsum.photos/150/80?random=${title.length}',
    );

    return InkWell(
      onTap: () {
        // ĐIỀU HƯỚNG ĐẾN MÀN HÌNH CHI TIẾT
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => TripDetailsPage(trip: miniTrip),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần hình ảnh/màu sắc tượng trưng
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: imageColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: DecorationImage(
                  image: NetworkImage(miniTrip.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(imageColor.withAlpha(77), BlendMode.dstATop),
                ),
              ),
            ),
            // Phần thông tin chuyến đi
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$memberCount members', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
