// lib/ui/Home/TripDetails/CheckList/checklist_tab.dart
import 'package:flutter/material.dart';
import 'package:moblie_btl/repository/checklist_repository.dart';
import 'checklist_item_dialog.dart';

// Color constants
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class ChecklistTabContent extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> members;

  const ChecklistTabContent({
    super.key,
    required this.tripId,
    required this.members,
  });

  @override
  State<ChecklistTabContent> createState() => _ChecklistTabContentState();
}

class _ChecklistTabContentState extends State<ChecklistTabContent> {
  final ChecklistRepository _repository = ChecklistRepository();
  List<Map<String, dynamic>> _membersInfo = [];
  Map<String, int> _memberItemCounts = {};
  Map<String, int> _memberCompletedCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembersInfo();
  }

  Future<void> _loadMembersInfo() async {
    setState(() => _isLoading = true);

    try {
      // Get member information from repository
      final membersInfo = await _repository.getTripMembersInfo(widget.members);

      // Load item counts for each member
      Map<String, int> itemCounts = {};
      Map<String, int> completedCounts = {};

      for (var member in membersInfo) {
        final userId = member['userId'] as String;
        final items = await _repository.getUserItems(widget.tripId, userId);
        itemCounts[userId] = items.length;
        completedCounts[userId] = items
            .where((item) => item.isCompleted)
            .length;
      }

      if (mounted) {
        setState(() {
          _membersInfo = membersInfo;
          _memberItemCounts = itemCounts;
          _memberCompletedCounts = completedCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách thành viên: $e')),
        );
      }
    }
  }

  void _navigateToMemberChecklist(Map<String, dynamic> memberData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberChecklistPage(
          tripId: widget.tripId,
          userId: memberData['userId'] as String,
          memberName: memberData['name'] as String,
        ),
      ),
    );
    // Refresh counts when returning from detail page
    _loadMembersInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_membersInfo.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có thành viên nào',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMembersInfo,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: ListView.separated(
          itemCount: _membersInfo.length,
          itemBuilder: (context, index) {
            return _buildMemberItem(_membersInfo[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 15),
        ),
      ),
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> memberData) {
    final userId = memberData['userId'] as String;
    final totalCount = _memberItemCounts[userId] ?? 0;
    final completedCount = _memberCompletedCounts[userId] ?? 0;
    final role = memberData['role'] as String? ?? 'member';
    final isAdmin = role == 'admin';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: mainBlueColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentGoldColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: accentGoldColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          // Name and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        memberData['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentGoldColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Admin',
                          style: TextStyle(
                            color: accentGoldColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  totalCount > 0
                      ? '$completedCount/$totalCount items hoàn thành'
                      : 'Chưa có vật dụng nào',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // See items button
          ElevatedButton(
            onPressed: () => _navigateToMemberChecklist(memberData),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: mainBlueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            child: const Text('Xem'),
          ),
        ],
      ),
    );
  }
}
