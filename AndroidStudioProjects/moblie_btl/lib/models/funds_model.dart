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
    return ContributionModel(
      id: docId,
      amount: map['amount'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      currency: map['currency'],
      date: (map['date'] as Timestamp?)?.toDate(),
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