import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String? id;
  num? amount;
  DateTime? createdAt;
  String? createdBy;
  DateTime? date;
  String? payerId;
  String? title;
  Map<String, num>? beneficiaries; // Thêm trường này

  ExpenseModel({
    this.id,
    this.amount,
    this.createdAt,
    this.createdBy,
    this.date,
    this.payerId,
    this.title,
    this.beneficiaries,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? safeParseTimestamp(dynamic rawDate) {
      if (rawDate is Timestamp) {
        return rawDate.toDate();
      } else if (rawDate is String) {
        return DateTime.tryParse(rawDate);
      }
      return null;
    }

    return ExpenseModel(
      id: docId,
      amount: map['amount'],
      createdAt: safeParseTimestamp(map['createdAt']),
      createdBy: map['createdBy'],
      date: safeParseTimestamp(map['date']),
      payerId: map['payerId'],
      title: map['title'],
      // Lấy dữ liệu beneficiaries từ map
      beneficiaries: map['beneficiaries'] != null ? Map<String, num>.from(map['beneficiaries']) : null,
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
      'beneficiaries': beneficiaries, // Thêm vào map để lưu
    };
  }
}
