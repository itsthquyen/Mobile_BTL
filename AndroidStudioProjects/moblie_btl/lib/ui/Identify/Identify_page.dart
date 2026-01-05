import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moblie_btl/model/id_document.dart';
import 'package:moblie_btl/repository/id_document_repository.dart';
import 'document_category_page.dart';

const Color primaryColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

/// Trang chính của tính năng Identify - Hiển thị các loại tài liệu định danh
class IdentifyPage extends StatelessWidget {
  const IdentifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    if (userId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để sử dụng tính năng này'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Header
          _buildHeader(user),

          // Danh sách các loại tài liệu
          Expanded(
            child: StreamBuilder<Map<DocumentCategory, int>>(
              stream: IdDocumentRepository().watchDocumentCounts(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final counts = snapshot.data ?? {};

                return ListView(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 20.0,
                  ),
                  children: [
                    _buildDocumentCard(
                      context: context,
                      userId: userId,
                      category: DocumentCategory.passport,
                      icon: Icons.public,
                      count: counts[DocumentCategory.passport] ?? 0,
                    ),
                    const SizedBox(height: 15),
                    _buildDocumentCard(
                      context: context,
                      userId: userId,
                      category: DocumentCategory.idCard,
                      icon: Icons.credit_card,
                      count: counts[DocumentCategory.idCard] ?? 0,
                    ),
                    const SizedBox(height: 15),
                    _buildDocumentCard(
                      context: context,
                      userId: userId,
                      category: DocumentCategory.driverLicense,
                      icon: Icons.badge,
                      count: counts[DocumentCategory.driverLicense] ?? 0,
                    ),
                    const SizedBox(height: 15),
                    _buildDocumentCard(
                      context: context,
                      userId: userId,
                      category: DocumentCategory.other,
                      icon: Icons.folder,
                      count: counts[DocumentCategory.other] ?? 0,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(User? user) {
    final displayName =
        user?.displayName ?? user?.email?.split('@')[0] ?? 'User';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              const Text(
                'Tài liệu của tôi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: accentGoldColor,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Greeting
          Text(
            'Xin chào, $displayName! 👋',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String userId,
    required DocumentCategory category,
    required IconData icon,
    required int count,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DocumentCategoryPage(userId: userId, category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: primaryColor, size: 30),
              ),
              const SizedBox(width: 20),

              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count tài liệu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
