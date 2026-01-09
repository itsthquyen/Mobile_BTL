// lib/ui/Home/TripDetails/CheckList/checklist_item_dialog.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moblie_btl/repository/checklist_repository.dart';
import 'package:moblie_btl/models/checklist_item.dart';
import 'package:moblie_btl/services/notification_service.dart';

// Color constants
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class MemberChecklistPage extends StatefulWidget {
  final String tripId;
  final String userId;
  final String memberName;

  const MemberChecklistPage({
    super.key,
    required this.tripId,
    required this.userId,
    required this.memberName,
  });

  @override
  State<MemberChecklistPage> createState() => _MemberChecklistPageState();
}

class _MemberChecklistPageState extends State<MemberChecklistPage> {
  final ChecklistRepository _repository = ChecklistRepository();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _newItemController = TextEditingController();
  final FocusNode _newItemFocus = FocusNode();

  bool _isAddingItem = false;
  bool _isSubmitting = false;
  String? _tripName;

  @override
  void initState() {
    super.initState();
    _loadTripName();
  }

  Future<void> _loadTripName() async {
    final tripDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();
    if (tripDoc.exists && mounted) {
      setState(() {
        _tripName = tripDoc.data()?['name'] ?? 'Chuyến đi';
      });
    }
  }

  @override
  void dispose() {
    _newItemController.dispose();
    _newItemFocus.dispose();
    super.dispose();
  }

  void _startAddingItem() {
    setState(() {
      _isAddingItem = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newItemFocus.requestFocus();
    });
  }

  void _cancelAddingItem() {
    setState(() {
      _isAddingItem = false;
      _newItemController.clear();
    });
  }

  Future<void> _confirmAddItem() async {
    final text = _newItemController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await _repository.addItem(widget.tripId, widget.userId, text);

      // Gửi thông báo cho các thành viên khác trong chuyến đi
      await _notificationService.notifyChecklistItemAdded(
        tripId: widget.tripId,
        tripName: _tripName ?? 'Chuyến đi',
        itemName: text,
      );

      setState(() {
        _isAddingItem = false;
        _newItemController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi thêm vật dụng: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _toggleItemCompletion(ChecklistItem item) async {
    try {
      await _repository.toggleItemCompletion(
        widget.tripId,
        widget.userId,
        item.id,
        !item.isCompleted,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
      }
    }
  }

  Future<void> _deleteItem(ChecklistItem item) async {
    try {
      await _repository.deleteItem(widget.tripId, widget.userId, item.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa vật dụng')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBlueColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checklist của ${widget.memberName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ChecklistItem>>(
        stream: _repository.watchUserItems(widget.tripId, widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
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
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final items = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                // Items list
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildItemTile(item),
                  ),
                ),

                // Add new item section
                if (_isAddingItem)
                  _buildAddItemInput()
                else
                  _buildAddItemButton(),

                // Empty state hint
                if (items.isEmpty && !_isAddingItem)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.checklist,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có vật dụng nào.\nNhấn "Thêm vật dụng mới..." để bắt đầu!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemTile(ChecklistItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: mainBlueColor,
                title: const Text(
                  'Xóa vật dụng?',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Bạn có chắc muốn xóa "${item.name}"?',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => _deleteItem(item),
      child: InkWell(
        onTap: () => _toggleItemCompletion(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                item.isCompleted
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: item.isCompleted ? Colors.greenAccent : accentGoldColor,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: item.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.white70,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddItemButton() {
    return InkWell(
      onTap: _startAddingItem,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: accentGoldColor.withValues(alpha: 0.8),
              size: 24,
            ),
            const SizedBox(width: 14),
            Text(
              'Thêm vật dụng mới...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentGoldColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_box_outline_blank_rounded,
            color: accentGoldColor.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _newItemController,
              focusNode: _newItemFocus,
              enabled: !_isSubmitting,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Nhập tên vật dụng...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _confirmAddItem(),
            ),
          ),
          // Cancel button
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
            onPressed: _isSubmitting ? null : _cancelAddingItem,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          // OK/Confirm button
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _confirmAddItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGoldColor,
              foregroundColor: mainBlueColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
        ],
      ),
    );
  }
}
