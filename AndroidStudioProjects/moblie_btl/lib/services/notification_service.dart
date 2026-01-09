// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moblie_btl/models/app_notification.dart';
import 'package:moblie_btl/repository/notification_repository.dart';

/// Service tạo thông báo tự động khi có thay đổi trong ứng dụng
///
/// - Trip-related notifications: Gửi cho TẤT CẢ members trong trip
/// - Personal notifications: Chỉ gửi cho user hiện tại
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final NotificationRepository _repository = NotificationRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy thông tin user hiện tại
  User? get _currentUser => _auth.currentUser;

  /// Lấy tên hiển thị của user hiện tại
  Future<String> _getCurrentUserName() async {
    final user = _currentUser;
    if (user == null) return 'Người dùng';

    // Thử lấy từ Firestore trước
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      return data?['displayName'] ??
          data?['name'] ??
          user.email?.split('@')[0] ??
          'Người dùng';
    }

    return user.displayName ?? user.email?.split('@')[0] ?? 'Người dùng';
  }

  /// Lấy danh sách member IDs từ trip (loại trừ người tạo thay đổi)
  Future<List<String>> _getTripMemberIds(
    String tripId, {
    bool excludeCurrentUser = true,
  }) async {
    final tripDoc = await _firestore.collection('trips').doc(tripId).get();
    if (!tripDoc.exists) return [];

    final members = tripDoc.data()?['members'] as Map<String, dynamic>?;
    if (members == null) return [];

    List<String> memberIds = members.keys.toList();

    // Loại trừ user hiện tại (người tạo thay đổi) nếu cần
    if (excludeCurrentUser && _currentUser != null) {
      memberIds.remove(_currentUser!.uid);
    }

    return memberIds;
  }

  // ============================================================
  // TRIP-RELATED NOTIFICATIONS (Gửi cho tất cả members trong trip)
  // ============================================================

  /// Thông báo khi thêm schedule mới
  Future<void> notifyScheduleAdded({
    required String tripId,
    required String tripName,
    required String scheduleName,
  }) async {
    print('🔔 NotificationService: notifyScheduleAdded called');
    print('   tripId: $tripId, tripName: $tripName');

    final creatorName = await _getCurrentUserName();
    print('   creatorName: $creatorName');

    // Lấy TẤT CẢ members (bao gồm cả current user để test)
    final memberIds = await _getTripMemberIds(
      tripId,
      excludeCurrentUser: false,
    );
    print('   memberIds: $memberIds');

    if (memberIds.isEmpty) {
      print('   ⚠️ No members found, skipping notification');
      return;
    }

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripSchedule,
      title: 'Lịch trình mới: $tripName',
      body: '$creatorName đã thêm hoạt động mới: $scheduleName.',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
    );

    print('   📤 Creating group notification...');
    await _repository.createGroupNotification(memberIds, notification);
    print('   ✅ Notification created successfully');
  }

  /// Thông báo khi cập nhật schedule
  Future<void> notifyScheduleUpdated({
    required String tripId,
    required String tripName,
    required String scheduleName,
  }) async {
    final creatorName = await _getCurrentUserName();
    final memberIds = await _getTripMemberIds(tripId);

    if (memberIds.isEmpty) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripSchedule,
      title: 'Cập nhật lịch trình: $tripName',
      body: '$creatorName đã cập nhật hoạt động: $scheduleName.',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
    );

    await _repository.createGroupNotification(memberIds, notification);
  }

  /// Thông báo khi thêm chi tiêu mới
  Future<void> notifyExpenseAdded({
    required String tripId,
    required String tripName,
    required String expenseTitle,
    required num amount,
    required String currency,
  }) async {
    final creatorName = await _getCurrentUserName();
    final memberIds = await _getTripMemberIds(tripId);

    if (memberIds.isEmpty) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripExpense,
      title: 'Chi tiêu mới: $tripName',
      body:
          '$creatorName đã thêm chi tiêu "$expenseTitle" - ${_formatAmount(amount)} $currency.',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
      data: {'amount': amount, 'title': expenseTitle},
    );

    await _repository.createGroupNotification(memberIds, notification);
  }

  /// Thông báo khi thêm quỹ mới
  Future<void> notifyFundAdded({
    required String tripId,
    required String tripName,
    required String fundTitle,
    required num amount,
    required String currency,
  }) async {
    final creatorName = await _getCurrentUserName();
    final memberIds = await _getTripMemberIds(tripId);

    if (memberIds.isEmpty) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripFund,
      title: 'Quỹ mới: $tripName',
      body:
          '$creatorName đã thêm quỹ "$fundTitle" - ${_formatAmount(amount)} $currency.',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
      data: {'amount': amount, 'title': fundTitle},
    );

    await _repository.createGroupNotification(memberIds, notification);
  }

  /// Thông báo khi thêm item vào checklist
  Future<void> notifyChecklistItemAdded({
    required String tripId,
    required String tripName,
    required String itemName,
  }) async {
    final creatorName = await _getCurrentUserName();
    final memberIds = await _getTripMemberIds(tripId);

    if (memberIds.isEmpty) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripChecklist,
      title: 'Checklist mới: $tripName',
      body: '$creatorName đã thêm mục "$itemName" vào checklist.',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
    );

    await _repository.createGroupNotification(memberIds, notification);
  }

  /// Thông báo khi tạo vote/bình chọn mới
  Future<void> notifyVoteCreated({
    required String tripId,
    required String tripName,
    required String locationName,
  }) async {
    print('🔔 NotificationService: notifyVoteCreated called');
    print(
      '   tripId: $tripId, tripName: $tripName, locationName: $locationName',
    );

    final creatorName = await _getCurrentUserName();
    print('   creatorName: $creatorName');

    // Lấy TẤT CẢ members (bao gồm cả current user để test)
    final memberIds = await _getTripMemberIds(
      tripId,
      excludeCurrentUser: false,
    );
    print('   memberIds: $memberIds');

    if (memberIds.isEmpty) {
      print('   ⚠️ No members found, skipping notification');
      return;
    }

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripVote,
      title: 'Bình chọn mới: $tripName',
      body: '$creatorName đã tạo bình chọn cho địa điểm "$locationName".',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
    );

    print('   📤 Creating group notification...');
    await _repository.createGroupNotification(memberIds, notification);
    print('   ✅ Notification created successfully');
  }

  /// Thông báo khi tạo chuyến đi mới
  Future<void> notifyTripCreated({
    required String tripId,
    required String tripName,
    required List<String> initialMemberIds,
  }) async {
    print('🔔 NotificationService: notifyTripCreated called');
    print(
      '   tripId: $tripId, tripName: $tripName, members: $initialMemberIds',
    );

    if (initialMemberIds.isEmpty) return;

    final creatorName = await _getCurrentUserName();

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripCreated,
      title: 'Chuyến đi mới: $tripName',
      body: 'Chuyến đi "$tripName" đã được tạo. Hãy bắt đầu lên kế hoạch ngay!',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: creatorName,
      createdAt: DateTime.now(),
    );

    print(
      '   📤 Creating group notification for creator and initial members...',
    );
    await _repository.createGroupNotification(initialMemberIds, notification);
    print('   ✅ Trip creation notification sent');
  }

  /// Thông báo khi có thành viên tham gia chuyến đi
  Future<void> notifyMemberJoined({
    required String tripId,
    required String tripName,
    required String memberName,
  }) async {
    // Notify all members including the new one
    final memberIds = await _getTripMemberIds(
      tripId,
      excludeCurrentUser: false,
    );

    if (memberIds.isEmpty) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.tripMember,
      title: 'Thành viên mới: $tripName',
      body: '$memberName đã tham gia chuyến đi.',
      tripId: tripId,
      tripName: tripName,
      createdBy: _currentUser?.uid ?? '',
      createdByName: memberName,
      createdAt: DateTime.now(),
    );

    await _repository.createGroupNotification(memberIds, notification);
  }

  // ============================================================
  // PERSONAL NOTIFICATIONS (Chỉ gửi cho user hiện tại)
  // ============================================================

  /// Thông báo khi cập nhật profile
  Future<void> notifyProfileUpdated() async {
    final user = _currentUser;
    if (user == null) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.profileUpdate,
      title: 'Cập nhật thông tin',
      body: 'Thông tin cá nhân của bạn đã được cập nhật thành công.',
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    await _repository.createNotification(user.uid, notification);
  }

  /// Thông báo khi thêm tài liệu định danh
  Future<void> notifyDocumentAdded({required String documentType}) async {
    final user = _currentUser;
    if (user == null) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.identifyDocument,
      title: 'Thêm tài liệu mới',
      body: 'Tài liệu $documentType của bạn đã được thêm thành công.',
      createdBy: user.uid,
      createdAt: DateTime.now(),
      data: {'documentType': documentType},
    );

    await _repository.createNotification(user.uid, notification);
  }

  /// Thông báo khi xóa tài liệu định danh
  Future<void> notifyDocumentDeleted({required String documentType}) async {
    final user = _currentUser;
    if (user == null) return;

    final notification = AppNotification(
      id: '',
      type: NotificationType.identifyDocument,
      title: 'Xóa tài liệu',
      body: 'Tài liệu $documentType của bạn đã được xóa.',
      createdBy: user.uid,
      createdAt: DateTime.now(),
      data: {'documentType': documentType},
    );

    await _repository.createNotification(user.uid, notification);
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Format số tiền hiển thị đẹp
  String _formatAmount(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }
}
