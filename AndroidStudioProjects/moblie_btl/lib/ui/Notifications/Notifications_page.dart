// lib/ui/notifications/notifications_page.dart

import 'package:flutter/material.dart';

// Màu chủ đạo
const primaryColor = Color(0xFF153359);
const accentColor = Color(0xFFF0F0FF); // Màu nền nhẹ đã dùng trong Login

// --- Model Dữ liệu Giả định ---
class NotificationModel {
  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;
  final String time;
  final bool isRead;

  const NotificationModel({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
    required this.time,
    this.isRead = false,
  });
}


class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Dữ liệu thông báo giả định
  final List<NotificationModel> mockNotifications = const [
    NotificationModel(
      title: 'Trip Update: City Trip',
      body: 'Hoang added a new activity: Lunch at Central Park.',
      icon: Icons.flight_takeoff,
      iconColor: Colors.blue,
      time: '3m ago',
      isRead: false,
    ),
    NotificationModel(
      title: 'Payment Request',
      body: 'You owe Alex 150,000 VND for accommodation.',
      icon: Icons.account_balance_wallet,
      iconColor: Colors.orange,
      time: '1 hour ago',
      isRead: false,
    ),
    NotificationModel(
      title: 'Document Verified',
      body: 'Your Passport document has been successfully verified.',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      time: 'Yesterday',
      isRead: true,
    ),
    NotificationModel(
      title: 'New Message from Alex',
      body: 'Check out the new flight option for our trip next month!',
      icon: Icons.chat_bubble,
      iconColor: Colors.purple,
      time: '2 days ago',
      isRead: true,
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 1. Header Card
          _buildHeader(),

          // 2. Danh sách Thông báo
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: mockNotifications.length,
              itemBuilder: (context, index) {
                final notification = mockNotifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: _NotificationCard(notification: notification),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title
          Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),

          // Subtitle/Count
          Text(
            'You have 2 new important notifications.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget Dành riêng: Notification Card ---

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Màu nền cho thông báo chưa đọc (để thu hút sự chú ý)
    final cardColor = notification.isRead ? Colors.white : accentColor;
    // Màu viền nhẹ cho thông báo chưa đọc
    final borderColor = notification.isRead ? Colors.grey.shade300 : primaryColor.withOpacity(0.3);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: borderColor, width: 1),
      ),
      color: cardColor,
      child: InkWell(
        onTap: () {
          // TODO: Logic đánh dấu đã đọc và điều hướng chi tiết
          debugPrint('Notification tapped: ${notification.title}');
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Icon (Tương ứng với loại thông báo)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),

              // 2. Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 3. Thời gian và dấu "chưa đọc"
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (!notification.isRead)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor, // Dấu chấm nhỏ cho thông báo chưa đọc
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}