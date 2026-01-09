import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String? id;
  num amount;
  DateTime createdAt;
  String createdBy;
  DateTime date;
  String payerId;
  String title;

  ExpenseModel({
    this.id,
    required this.amount,
    required this.createdAt,
    required this.createdBy,
    required this.date,
    required this.payerId,
    required this.title,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      amount: map['amount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      payerId: map['payerId'] ?? '',
      title: map['title'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'date': Timestamp.fromDate(date),
      'payerId': payerId,
      'title': title,
    };
  }
}