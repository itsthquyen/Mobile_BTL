import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String? id;
  String? coverUrl;
  DateTime? createdAt;
  String? createdBy;
  String? currency;
  DateTime? endDate;
  String? joinCode;
  Map<String, String>? members;
  String? name;
  DateTime? startDate;
  DateTime? updatedAt;

  TripModel({
    this.id,
    this.coverUrl,
    this.createdAt,
    this.createdBy,
    this.currency,
    this.endDate,
    this.joinCode,
    this.members,
    this.name,
    this.startDate,
    this.updatedAt,
  });

  // Hàm fromMap: Chuyển từ Map (dữ liệu Firestore) sang Object
  factory TripModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TripModel(
      id: docId,
      coverUrl: map['coverUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'],
      currency: map['currency'],
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      joinCode: map['joinCode'],
      members: map['members'] != null ? Map<String, String>.from(map['members']) : null,
      name: map['name'],
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Hàm toMap: Chuyển từ Object sang Map để đẩy lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'coverUrl': coverUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdBy': createdBy,
      'currency': currency,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'joinCode': joinCode,
      'members': members,
      'name': name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }
}