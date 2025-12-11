import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import các file cần thiết theo cấu trúc thư mục của bạn
import 'add_schedule.dart'; // Chứa AddScheduleModal
import './Expenses/add_expense.dart'; // Chứa AddExpenseModal
import './Expenses/expense_page.dart'; // Chứa ExpensesTabContent

// ********************************************
// ********** 1. TRIP MODEL (Mẫu) *************
// ********************************************
class Trip {
  final String title;
  final String subtitle;
  final String imageUrl;

  Trip({required this.title, required this.subtitle, required this.imageUrl});
}

// ********************************************
// ******* 2. ĐỊNH NGHĨA MÀU SẮC CHỦ ĐẠO ******
// ********************************************
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

// ********************************************
// ******** 3. WIDGET CHI TIẾT CHUYẾN ĐI *******
// ********************************************
class TripDetailsPage extends StatefulWidget {
  final Trip trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  int _selectedIndex = 0; // Mặc định là Schedule (0)
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
          // 1. Phần Header màu xanh đậm (Fixed)
          _buildHeader(context),

          // 2. Phần Thân (Gradient + Tab Bar + Nội dung)
          Expanded(
            child: Stack(
              children: [
                // Lớp nền Gradient
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

                // Nội dung chính: Tab Bar và Content
                Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildCustomTabBar(),

                    Expanded(
                      child: _buildPageContent(), // Hiển thị nội dung theo tab
                    ),
                  ],
                ),

                // Nút Add Button (CĂN SÁT DƯỚI)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0), // Vị trí sát dưới
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

  // --- Hàm Chính: Lựa chọn nội dung Tab ---
  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return const ScheduleTabContent();
      case 1:
        return const ExpensesTabContent();
    // Thêm các case cho Checklist và Votes khi triển khai
      default:
        return const Center(child: Text('Content Placeholder', style: TextStyle(color: Colors.white)));
    }
  }

  // --- Widget Header (Phần trên cùng) ---
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
          // Nút Back, Title app, Search, More
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
          // Icon ô dù (Placeholder)
          const Icon(
            Icons.beach_access,
            size: 60,
            color: Color(0xFFFFCC80),
          ),
          const SizedBox(height: 10),
          // Tiêu đề chính (Lấy từ Trip object)
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

  // --- Widget Tab Bar tùy chỉnh ---
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

  // --- Widget nút tròn "Add" (FAB) ---
  Widget _buildAddButton() {
    String label = _selectedIndex == 0 ? "Add Schedule" :
    _selectedIndex == 1 ? "Add Expense" : "Add Item";

    return InkWell(
      onTap: () {
        if (_selectedIndex == 0) {
          _showAddScheduleModal(context);
        } else if (_selectedIndex == 1) {
          _showAddExpenseModal(context);
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

  // --- Hàm gọi Modal Lịch trình ---
  void _showAddScheduleModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        // Giả định AddScheduleModal đã được import từ add_schedule.dart
        return const AddScheduleModal();
      },
    );
  }

  // --- Hàm gọi Modal Chi tiêu ---
  void _showAddExpenseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        // GỌI WIDGET TỪ add_expense.dart
        return const AddExpenseModal();
      },
    );
  }
} // <--- Dấu đóng ngoặc của _TripDetailsPageState đã được đặt đúng chỗ

// ********************************************
// ******** 4. NỘI DUNG TAB SCHEDULE **********
// ********************************************
// CLASS NÀY PHẢI ĐƯỢC ĐỊNH NGHĨA Ở TOP LEVEL (NGOÀI CLASS _TripDetailsPageState)
class ScheduleTabContent extends StatelessWidget {
  const ScheduleTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Icon(
            Icons.manage_search_rounded,
            size: 80,
            color: accentGoldColor.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Schedule Yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add a schedule by tapping on the "+" to start tracking and splitting your schedules',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}