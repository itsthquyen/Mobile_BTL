import 'package:cloud_firestore/cloud_firestore.dart';

class ContributionModel {
  String? id;
  num? amount;
  DateTime? createdAt;
  String? currency;
  DateTime? date;
  String? note;
  String? proofImage;
  String? userId;

  ContributionModel({
    this.id,
    this.amount,
    this.createdAt,
    this.currency,
    this.date,
    this.note,
    this.proofImage,
    this.userId,
  });

  factory ContributionModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime? safeParseTimestamp(dynamic rawDate) {
      if (rawDate is Timestamp) {
        return rawDate.toDate();
      } else if (rawDate is String) {
        return DateTime.tryParse(rawDate);
      }
      return null;
    }

    return ContributionModel(
      id: docId,
      amount: map['amount'],
      createdAt: safeParseTimestamp(map['createdAt']),
      currency: map['currency'],
      date: safeParseTimestamp(map['date']),
      note: map['note'],
      proofImage: map['proofImage'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'currency': currency,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'note': note,
      'proofImage': proofImage,
      'userId': userId,
    };
  }
}
