import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moblie_btl/models/expenses_model.dart';
import 'package:moblie_btl/models/funds_model.dart';
import 'package:moblie_btl/services/notification_service.dart';

class ExpenseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  Stream<List<ExpenseModel>> getExpenses(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        // .orderBy('date', descending: true) // Xóa sắp xếp ở đây
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), docId: doc.id))
          .toList();
      // Sắp xếp trong Dart để xử lý dữ liệu không đồng nhất
      list.sort((a, b) {
        final dateA = a.date;
        final dateB = b.date;
        if (dateB == null) return -1;
        if (dateA == null) return 1;
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  Stream<List<ContributionModel>> getFunds(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('funds')
        // .orderBy('date', descending: true) // Xóa sắp xếp ở đây
        .snapshots()
        .map((snapshot) {
      var list = snapshot.docs
          .map((doc) => ContributionModel.fromMap(doc.data(), docId: doc.id))
          .toList();
      // Sắp xếp trong Dart
      list.sort((a, b) {
        final dateA = a.date;
        final dateB = b.date;
        if (dateB == null) return -1;
        if (dateA == null) return 1;
        return dateB.compareTo(dateA);
      });
      return list;
    });
  }

  Future<void> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required String payerId,
    required DateTime date,
    required String tripName,
  }) async {
    final newExpense = ExpenseModel(
      title: title,
      amount: amount,
      payerId: payerId,
      date: date,
      createdBy: _auth.currentUser?.uid,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .add(newExpense.toMap());

    try {
      await _notificationService.notifyExpenseAdded(
        tripId: tripId,
        tripName: tripName,
        expenseTitle: title,
        amount: amount,
        currency: 'VND',
      );
    } catch (e) {
      print("Notification Error on addExpense: $e");
    }
  }

  Future<void> addFund({
    required String tripId,
    required double amount,
    required String userId,
    required DateTime date,
    required String tripName,
  }) async {
    final newFund = ContributionModel(
      userId: userId,
      amount: amount,
      date: date,
      note: 'Quỹ',
      currency: 'VND',
      proofImage: '',
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('funds')
        .add(newFund.toMap());

    try {
      await _notificationService.notifyFundAdded(
        tripId: tripId,
        tripName: tripName,
        fundTitle: 'Quỹ',
        amount: amount,
        currency: 'VND',
      );
    } catch (e) {
      print("Notification Error on addFund: $e");
    }
  }
}
