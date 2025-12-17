import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ui/ui/profile/create_profile_page.dart'; // Thay đổi import

// HomePage được định nghĩa ở đây để code có thể chạy
// Bạn sẽ thay thế nó bằng file trang chủ thật của mình
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang Chủ")),
      body: const Center(child: Text("Chào mừng đến với ứng dụng!")),
    );
  }
}

// Dữ liệu cho các màn hình onboarding
class OnboardingInfo {
  final IconData icon;
  final String title;
  final String description;

  OnboardingInfo({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final controller = PageController();
  int _currentPageIndex = 0; // Dùng để theo dõi trang hiện tại

  final List<OnboardingInfo> onboardingData = [
    OnboardingInfo(
      icon: Icons.travel_explore,
      title: 'Tìm chuyến bay',
      description: 'Tìm kiếm chuyến bay nhanh chóng đến mọi điểm đến bạn mong muốn.',
    ),
    OnboardingInfo(
      icon: Icons.add_location_alt_outlined,
      title: 'Lên kế hoạch phiêu lưu',
      description: 'Thêm các chuyến đi mới, sắp xếp một cách dễ dàng và hiệu quả.',
    ),
    OnboardingInfo(
      icon: Icons.edit_calendar_outlined,
      title: 'Duy trì lịch trình',
      description: 'Quản lý các chuyến đi, nhận thông báo và không bỏ lỡ kế hoạch nào.',
    ),
    OnboardingInfo(
      icon: Icons.wallet_outlined,
      title: 'Theo dõi chi phí',
      description: 'Ghi lại chi phí, thiết lập ngân sách và quản lý tài chính chặt chẽ.',
    ),
    OnboardingInfo(
      icon: Icons.playlist_add_check_circle_outlined,
      title: 'Hoàn thành danh sách',
      description: 'Tạo danh sách những việc cần làm để không bỏ sót bất kỳ mục nào.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onDone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'hasSeenOnboarding': true});

      if (mounted) {
        // Chuyển đến trang tạo hồ sơ
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const CreateProfilePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi lưu trạng thái: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lớp 1: Nền Gradient và Ảnh
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B3A5E), Color(0xFF0A1A2E)],
              ),
            ),
          ),
          // Lớp 2: Nội dung chính
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    // Vô hiệu hóa vuốt
                    physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = onboardingData[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Icon(item.icon, size: 120, color: Colors.white),
                          const SizedBox(height: 32),
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Chỉ hiển thị tên App ở trang đầu tiên
                          if (index == 0) ...[
                            const SizedBox(height: 60),
                            const Text(
                              'TRIPSYNC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your ultimate journey planner',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const Spacer(),
                        ],
                      );
                    },
                  ),
                ),
                // Phần giao diện dưới cùng
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: controller,
                        count: onboardingData.length,
                        effect: const WormEffect(
                          spacing: 12,
                          dotHeight: 10,
                          dotWidth: 10,
                          dotColor: Colors.white24,
                          activeDotColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, // Nút rộng hết cỡ
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF153359),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_currentPageIndex == onboardingData.length - 1) {
                              _onDone();
                            } else {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: Text(
                            _currentPageIndex == 0 ? 'Bắt đầu' : 'Tiếp',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lớp 4: Nút quay lại (chỉ hiện từ trang thứ 2)
          if (_currentPageIndex > 0)
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: () {
                  controller.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
