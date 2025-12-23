import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Import để dùng hàm Random
import 'package:moblie_btl/ui/Identify/Identify_page.dart';
import 'package:moblie_btl/ui/Notifications/Notifications_page.dart';
import 'package:moblie_btl/ui/Profile/UserProfile.dart';
import 'package:moblie_btl/ui/Home/TripDetails/trip_details.dart';
import 'package:moblie_btl/ui/Home/new_Trip/new_Trip.dart';
import '../../model/trip.dart';

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

// ************ TRIPSYNC CONTENT PAGE ***********

class TripSyncContentPage extends StatelessWidget {
  const TripSyncContentPage({super.key});

  /// ===== LOAD ALL TRIPS (Để chia thành My Trips & Discovery) =====
  Stream<List<Trip>> _getAllTrips() {
    // Tăng limit lên 50 để có nhiều lựa chọn ngẫu nhiên hơn
    return FirebaseFirestore.instance
        .collection('trips')
        // .orderBy('startDate', descending: true) // Bật lại khi đã tạo Index
        .limit(50) 
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Trip.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<Trip>>(
      stream: _getAllTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
           return const Scaffold(body: Center(child: Text("Loading trips..."))); 
        }

        final allTrips = snapshot.data ?? [];
        
        // --- PHÂN LOẠI TRIPS ---
        final String uid = user?.uid ?? "";
        final String email = user?.email ?? ""; // Lấy cả email để check
        
        // 1. My Trips: User có trong list (bằng UID hoặc Email)
        final myTrips = allTrips.where((trip) {
          return trip.members.containsKey(uid) || trip.members.containsKey(email);
        }).toList();
        
        // 2. Discovery Trips: User KHÔNG có trong list
        final discoveryTrips = allTrips.where((trip) {
          return !trip.members.containsKey(uid) && !trip.members.containsKey(email);
        }).toList();

        // TRỘN NGẪU NHIÊN danh sách Discovery
        discoveryTrips.shuffle(); 

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // === PHẦN 1: KHÁM PHÁ / NGẪU NHIÊN (SLIDER/PAGEVIEW) ===
              Transform.translate(
                offset: const Offset(0, -60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, left: 24),
                      child: Text(
                        "Explore new journeys ✨",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    if (discoveryTrips.isNotEmpty)
                      SizedBox(
                        height: 320, // Chiều cao cho PageView
                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.85), // Hiển thị 1 phần card sau
                          itemCount: discoveryTrips.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 15.0), // Khoảng cách giữa các card
                              child: _buildTripCard(
                                context: context,
                                trip: discoveryTrips[index],
                              ),
                            );
                          },
                        ),
                      )
                    else 
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildEmptyDiscoveryCard(),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pager Indicator (Chỉ hiển thị tượng trưng nếu có nhiều hơn 1 trang)
                    if (discoveryTrips.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(min(5, discoveryTrips.length), (index) {
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

                    // === PHẦN 2: MY TRIPS (CỦA TÔI) ===
                    const Text(
                      'My Trips',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const SizedBox(height: 15),

                    if (myTrips.isNotEmpty)
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: myTrips.length,
                          separatorBuilder: (_,__) => const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            return _buildMiniTripCard(
                              context: context,
                              trip: myTrips[index],
                            );
                          },
                        ),
                      )
                    else
                       _buildEmptyMyTrips(),

                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyDiscoveryCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: const Center(
        child: Text("No trips to discover yet!", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
  
  Widget _buildEmptyMyTrips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        children: const [
          Icon(Icons.luggage, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "You haven't joined any trips yet.",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            "Click (+) to create one!",
             style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220, 
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
              Text('Discover & Join 🌏', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
            ],
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const NetworkImage('https://picsum.photos/50/50?random=2'),
          ),
        ],
      ),
    );
  }

  // --- Widget Card Chuyến Đi Lớn (Discovery Trip) ---
  Widget _buildTripCard({required BuildContext context, required Trip trip}) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell( 
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
                trip.coverUrl,
                fit: BoxFit.cover, height: 200, width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200, color: Colors.grey[300], child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       const Icon(Icons.person, size: 16, color: Colors.grey),
                       const SizedBox(width: 4),
                       Text('${trip.memberCount} members', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
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

  Widget _buildMiniTripCard({
    required BuildContext context,
    required Trip trip,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => TripDetailsPage(trip: trip),
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
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.teal, 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: DecorationImage(
                  image: NetworkImage(trip.coverUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.teal.withAlpha(77), BlendMode.dstATop),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text('Joined', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)), 
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${trip.memberCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
