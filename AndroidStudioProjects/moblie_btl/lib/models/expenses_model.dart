import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String? id;
  num? amount;
  DateTime? createdAt;
  String? createdBy;
  DateTime? date;
  String? payerId;
  String? title;

  ExpenseModel({
    this.id,
    this.amount,
    this.createdAt,
    this.createdBy,
    this.date,
    this.payerId,
    this.title,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ExpenseModel(
      id: docId,
      amount: map['amount'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'],
      date: (map['date'] as Timestamp?)?.toDate(),
      payerId: map['payerId'],
      title: map['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'payerId': payerId,
      'title': title,
    };
  }
}