// lib/ui/Home/TripDetails/trip_details.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moblie_btl/ui/Home/TripDetails/schedule_tab.dart';

// Import các file cần thiết
import 'CheckList/checklist_tab.dart';
import 'Vote/add_vote.dart';
import 'Vote/votes_tab.dart';
import 'add_schedule.dart';
// Import file container quản lý, không import add_expense hay add_fund nữa
import './Expenses/expense_fund_container.dart';
import './Expenses/expense_page.dart';

class Trip {
  final String title;
  final String subtitle;
  final String imageUrl;
  Trip({required this.title, required this.subtitle, required this.imageUrl});
}

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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: mainBlueColor,
      body: Column(
        children: [
          _buildHeader(context),
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
                    Expanded(
                      child: _buildPageContent(),
                    ),
                  ],
                ),
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
        return const ScheduleTabContent();
      case 1:
        return const ExpensesTabContent();
      case 2:
        return const ChecklistTabContent();
      case 3: // *** THÊM CASE MỚI CHO VOTES ***
        return const VotesTabContent();
      default:
        return const Center(child: Text('Content Placeholder', style: TextStyle(color: Colors.white)));
    }
  }



  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Gọi widget quản lý trung gian
        return const FractionallySizedBox(
          heightFactor: 0.9, // Chiếm 90% chiều cao màn hình
          child: ExpenseFundContainer(),
        );
      },
    );
  }

  void _showAddScheduleModal(BuildContext context) {
    {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          // Gọi widget quản lý trung gian
          return const FractionallySizedBox(
            heightFactor: 0.9, // Chiếm 90% chiều cao màn hình
            child: AddScheduleModal(),
          );
        },
      );
    }
  }

  void _showAddVoteModal(BuildContext context) {
    {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          // Gọi widget quản lý trung gian
          return const FractionallySizedBox(
            heightFactor: 0.9, // Chiếm 90% chiều cao màn hình
            child: AddVoteLocationModal(),
          );
        },
      );
    }
  }

  // ... (Tất cả các hàm build còn lại của trip_details.dart giữ nguyên)
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
      decoration: const BoxDecoration(
        color: mainBlueColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
                children: const [
                  Icon(Icons.search, color: Colors.white, size: 24),
                  SizedBox(width: 16),
                  Icon(Icons.more_horiz, color: Colors.white, size: 24),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.beach_access,
            size: 60,
            color: Color(0xFFFFCC80),
          ),
          const SizedBox(height: 10),
          Text(
            widget.trip.title,
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    // Dòng code đã cập nhật
    String label = _selectedIndex == 0 ? "Add Schedule" :
    _selectedIndex == 1 ? "Add Expense" :
    _selectedIndex == 2 ? "Add Item" : // Cho Checklist
    "Add Location";
    return InkWell(
      onTap: () {
          if (_selectedIndex == 0) {
            _showAddScheduleModal(context);
          } else if (_selectedIndex == 1) {
            _showAddExpenseModal(context);
          } else if (_selectedIndex ==  2) {
            print("Add Checklist Item tapped");
          } else if (_selectedIndex == 3) {
           _showAddVoteModal(context) ;
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
            Icon(Icons.add, color: Colors.white, size: 24),
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

