import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moblie_btl/ui/Identify/Identify_page.dart';
import 'package:moblie_btl/ui/Notifications/Notifications_page.dart';
import 'package:moblie_btl/ui/Profile/UserProfile.dart';
import 'package:moblie_btl/ui/Home/TripDetails/trip_details.dart';
import 'package:moblie_btl/ui/Home/new_Trip/new_Trip.dart';
import 'package:moblie_btl/repository/notification_repository.dart';
import '../../models/trip.dart';
import '../../services/ai_service.dart';
import 'dart:math';

const primaryColor = Color(0xFF153359);

class TripsyncPage extends StatefulWidget {
  const TripsyncPage({super.key});

  @override
  State<TripsyncPage> createState() => _TripsyncPageState();
}

class _TripsyncPageState extends State<TripsyncPage> {
  int _selectedIndex = 0;
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  late final List<Widget> _pages = [
    TripSyncContentPage(
      onNotificationTap: () => _onItemTapped(3),
    ),
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
    final userId = FirebaseAuth.instance.currentUser?.uid;

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
            _buildNavItem(Icons.qr_code_scanner, 'Định danh', 1),
            const SizedBox(width: 48.0),
            _buildNotificationNavItem(userId),
            _buildNavItem(Icons.person_outline, 'Cá nhân', 4),
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

  /// Widget đặc biệt cho Notification với badge hiển thị số thông báo chưa đọc
  Widget _buildNotificationNavItem(String? userId) {
    final actualIndex = 2;
    final isSelected = _selectedIndex == actualIndex;

    return InkWell(
      onTap: () => _onItemTapped(3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.notifications_none,
                  color: isSelected ? primaryColor : Colors.grey,
                ),
                if (userId != null)
                  StreamBuilder<int>(
                    stream: _notificationRepository.watchUnreadCount(userId),
                    builder: (context, snapshot) {
                      final unreadCount = snapshot.data ?? 0;
                      if (unreadCount == 0) return const SizedBox.shrink();

                      return Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ************ TRIPSYNC CONTENT PAGE ***********

class TripSyncContentPage extends StatefulWidget {
  final VoidCallback? onNotificationTap;

  const TripSyncContentPage({super.key, this.onNotificationTap});

  @override
  State<TripSyncContentPage> createState() => _TripSyncContentPageState();
}

class _TripSyncContentPageState extends State<TripSyncContentPage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  List<Trip>? _cachedDiscoveryTrips;
  String? _lastUid;

  late Stream<List<Trip>> _tripsStream;

  @override
  void initState() {
    super.initState();
    _tripsStream = _getAllTrips();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Stream<List<Trip>> _getAllTrips() {
    return FirebaseFirestore.instance
        .collection('trips')
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Trip.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  bool _isGenerating = false;

  Future<void> _generateAndSaveMockTrips() async {
    setState(() => _isGenerating = true);

    try {
      final aiService = AiService();
      final mockData = await aiService.generateSampleTrips();

      if (mockData.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI chưa nghĩ ra ý tưởng nào, hãy thử lại!")));
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      final collection = FirebaseFirestore.instance.collection('trips');

      final random = Random();
      final covers = [
        'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1', // Boat
        'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800', // Travel van
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e', // Beach
        'https://images.unsplash.com/photo-1493246507139-91e8fad9978e', // Mountain
        'https://images.unsplash.com/photo-1504609773096-104ff2c73ba4', // Food
      ];

      for (var data in mockData) {
        final docRef = collection.doc();
        final startDate = DateTime.now().add(Duration(days: random.nextInt(30)));
        final endDate = startDate.add(const Duration(days: 3)); // Default range

        batch.set(docRef, { // Removed await
          'name': data['name'],
          'coverUrl': covers[random.nextInt(covers.length)],
          'members': {}, // Empty members = Discovery trip
          'memberCount': 0,
          'startDate': startDate,
          'endDate': endDate,
          'description': data['description'],
          'destination': data['destination'],
          'generatedByAI': true,
        });

        // Xử lý Lịch trình (Itinerary)
        if (data['days'] != null && data['days'] is List) {
          final days = data['days'] as List;
          final itineraryCollection = docRef.collection('itinerary');

          for (var dayItem in days) {
            final dayIndex = (dayItem['day'] as int? ?? 1) - 1; // 0-based
             final currentDate = startDate.add(Duration(days: dayIndex));

            if (dayItem['activities'] != null && dayItem['activities'] is List) {
              final activities = dayItem['activities'] as List;
              for (var act in activities) {
                final startHour = act['startHour'] as int? ?? 8;
                final duration = (act['durationHours'] as num? ?? 1.0).toDouble();
                
                final actStartTime = DateTime(currentDate.year, currentDate.month, currentDate.day, startHour, 0);
                final actEndTime = actStartTime.add(Duration(minutes: (duration * 60).toInt()));

                final actDoc = itineraryCollection.doc();
                batch.set(actDoc, {
                  'title': act['title'] ?? 'Hoạt động',
                  'locationName': act['location'] ?? '',
                  'description': act['description'] ?? '',
                  'startTime': Timestamp.fromDate(actStartTime),
                  'endTime': Timestamp.fromDate(actEndTime),
                  'type': 'activity',
                  'status': 'planned',
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }
            }
          }
        }
      }

      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã thêm ${mockData.length} chuyến đi mới từ AI!")));
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<Trip>>(
      stream: _tripsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedDiscoveryTrips == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Lỗi khi tải chuyến đi")),
          );
        }

        final allTrips = snapshot.data ?? [];

        final String uid = user?.uid ?? "";
        final String email = user?.email ?? "";

        final myTrips = allTrips.where((trip) {
          return trip.members.containsKey(uid) ||
              trip.members.containsKey(email);
        }).toList();

        final rawDiscoveryTrips = allTrips.where((trip) {
          return !trip.members.containsKey(uid) &&
              !trip.members.containsKey(email);
        }).toList();

        if (_cachedDiscoveryTrips == null ||
            _lastUid != uid ||
            !_areTripsEqual(_cachedDiscoveryTrips!, rawDiscoveryTrips)) {
          _cachedDiscoveryTrips = List.from(rawDiscoveryTrips)..shuffle();
          _lastUid = uid;
        }

        final discoveryTrips = _cachedDiscoveryTrips!;

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Transform.translate(
                offset: const Offset(0, -60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 24, right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Khám phá hành trình mới ✨",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isGenerating)
                            const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          else
                            GestureDetector(
                              onTap: _generateAndSaveMockTrips,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.auto_awesome, color: Colors.yellow, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      "Tạo mẫu",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    if (discoveryTrips.isNotEmpty)
                      SizedBox(
                        height: 320,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: discoveryTrips.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 15.0),
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
                    if (discoveryTrips.length > 1)
                      ListenableBuilder(
                        listenable: _pageController,
                        builder: (context, child) {
                          double page = 0;
                          if (_pageController.hasClients &&
                              _pageController.page != null) {
                            page = _pageController.page!;
                          }
                          return _buildSmoothPageIndicator(
                            discoveryTrips.length,
                            page,
                          );
                        },
                      ),
                    const SizedBox(height: 30),
                    const Text(
                      'Chuyến đi của tôi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (myTrips.isNotEmpty)
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: myTrips.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 15),
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

  bool _areTripsEqual(List<Trip> a, List<Trip> b) {
    if (a.length != b.length) return false;
    final aIds = a.map((t) => t.id).toSet();
    final bIds = b.map((t) => t.id).toSet();
    return aIds.containsAll(bIds) && bIds.containsAll(aIds);
  }

  Widget _buildSmoothPageIndicator(int itemCount, double currentPage) {
    final int currentIndex = currentPage.round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: isActive ? 24.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
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
        child: Text(
          "Chưa có chuyến đi nào để khám phá!",
          style: TextStyle(color: Colors.grey),
        ),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: const [
          Icon(Icons.luggage, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Bạn chưa tham gia chuyến đi nào.",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            "Nhấn (+) để tạo chuyến đi!",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
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
              Text(
                'TripSync',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Lên kế hoạch, Trải nghiệm, Chia sẻ', // Đã sửa
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: widget.onNotificationTap,
              ),
              StreamBuilder<int>(
                stream: _notificationRepository.watchUnreadCount(
                    FirebaseAuth.instance.currentUser?.uid ?? ''),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  if (unreadCount == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard({required BuildContext context, required Trip trip}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsPage(trip: trip),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                trip.coverUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text(
                        trip.startDate != null
                            ? '${trip.startDate!.day}/${trip.startDate!.month}/${trip.startDate!.year}'
                            : 'Chưa có ngày',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text('${trip.memberCount} thành viên'),
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

  Widget _buildMiniTripCard({required BuildContext context, required Trip trip}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsPage(trip: trip),
          ),
        );
      },
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          image: DecorationImage(
            image: NetworkImage(trip.coverUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${trip.memberCount} thành viên',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
