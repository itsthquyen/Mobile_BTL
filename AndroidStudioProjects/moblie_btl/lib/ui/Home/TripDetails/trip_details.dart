// lib/ui/Home/TripDetails/trip_details.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblie_btl/models/trip.dart'; // Import Trip models chính
import 'package:moblie_btl/ui/Home/TripDetails/schedule_tab.dart';

// Import các file cần thiết
import 'CheckList/checklist_tab.dart';
import 'Vote/add_vote.dart';
import 'Vote/votes_tab.dart';
import 'add_schedule.dart';
// Import file container quản lý, không import add_expense hay add_fund nữa
import './Expenses/expense_fund_container.dart';
import './Expenses/expense_page.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class TripDetailsPage extends StatefulWidget {
  final Trip trip;
  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  int _selectedIndex = 0;
  final List<String> _tabs = ["Schedule", "Expenses", "Checklist", "Votes"];
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    _determineUserRole();
  }

  void _determineUserRole() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserRole = widget.trip.members[user.uid];
      });
    }
  }

  // --- HÀM XỬ LÝ CÁC LỰA CHỌN TRONG MENU ---
  void _onMenuItemSelected(String value) {
    switch (value) {
      case 'share':
        _showShareDialog();
        break;
      case 'delete':
        _showDeleteConfirmDialog();
        break;
    }
  }

  // --- DIALOG CHIA SẺ MÃ (GIAO DIỆN MỚI) ---
  void _showShareDialog() {
    final joinCode = widget.trip.joinCode;
    if (joinCode == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: mainBlueColor, // Nền tối
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Chia sẻ mã tham gia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gửi mã này cho bạn bè để họ tham gia chuyến đi:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: joinCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép vào bộ nhớ tạm!')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C436D), // darkFieldColor
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      joinCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.copy, size: 20, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG XÁC NHẬN XÓA (GIAO DIỆN MỚI) ---
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: mainBlueColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Xóa chuyến đi?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Hành động này không thể hoàn tác. Toàn bộ dữ liệu của chuyến đi sẽ bị xóa vĩnh viễn.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTrip();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- HÀM XÓA CHUYẾN ĐI KHỎI FIRESTORE ---
  Future<void> _deleteTrip() async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.trip.id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa chuyến đi thành công.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa chuyến đi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = currentUserRole == 'admin';

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: mainBlueColor,
      body: Column(
        children: [
          _buildHeader(context, isAdmin),
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE8ECF2),
                        const Color(0xFF8DA0C1),
                        mainBlueColor.withOpacity(0.8),
                        mainBlueColor,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCustomTabBar(),
                    Expanded(child: _buildPageContent()),
                  ],
                ),
                // Show add button:
                // - Admin can add to all tabs
                // - All members can add to Votes tab (index 3)
                if (isAdmin || _selectedIndex == 3)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: _buildAddButton(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return ScheduleTabContent(tripId: widget.trip.id);
      case 1:
        return ExpensesTabContent(tripId: widget.trip.id);
      case 2:
        return ChecklistTabContent(
          tripId: widget.trip.id,
          members: widget.trip.members,
        );
      case 3:
        return VotesTabContent(
          tripId: widget.trip.id,
          members: widget.trip.members,
        );
      default:
        return const Center(
          child: Text(
            'Content Placeholder',
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  void _showAddScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: AddScheduleModal(tripId: widget.trip.id),
        );
      },
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ExpenseFundContainer(tripId: widget.trip.id),
        );
      },
    );
  }

  void _showAddVoteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: AddVoteLocationModal(tripId: widget.trip.id),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isAdmin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
      decoration: const BoxDecoration(
        color: mainBlueColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Tripsync",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: _onMenuItemSelected,
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 24,
                    ),
                    color: mainBlueColor, // Nền cho menu
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'share',
                            child: ListTile(
                              leading: Icon(Icons.share, color: Colors.white),
                              title: Text(
                                'Chia sẻ mã tham gia',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          if (isAdmin)
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  'Xóa chuyến đi',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                        ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.beach_access, size: 60, color: Color(0xFFFFCC80)),
          const SizedBox(height: 10),
          Text(
            widget.trip.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: mainBlueColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isSelected = index == _selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? mainBlueColor : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddButton() {
    String label = _selectedIndex == 0
        ? "Add Schedule"
        : _selectedIndex == 1
        ? "Add Expense"
        : _selectedIndex == 2
        ? "Add Item"
        : "Add Location";
    return InkWell(
      onTap: () {
        if (_selectedIndex == 0) {
          _showAddScheduleModal(context);
        } else if (_selectedIndex == 1) {
          _showAddExpenseModal(context);
        } else if (_selectedIndex == 2) {
          print("Add Checklist Item tapped");
        } else if (_selectedIndex == 3) {
          _showAddVoteModal(context);
        }
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.55,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
