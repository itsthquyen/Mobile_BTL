import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  String? id;
  String type;           // Trong ảnh là "Type"
  String documentNumber;
  DateTime? expiryDate;
  String fullName;
  String imageFrontUrl;

  DocumentModel({
    this.id,
    required this.type,
    required this.documentNumber,
    this.expiryDate,
    required this.fullName,
    required this.imageFrontUrl,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DocumentModel(
      id: docId,
      type: map['Type'] ?? '', // Lưu ý chữ 'T' viết hoa theo ảnh
      documentNumber: map['documentNumber'] ?? '',
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      fullName: map['fullName'] ?? '',
      imageFrontUrl: map['imageFrontUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Type': type,
      'documentNumber': documentNumber,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'fullName': fullName,
      'imageFrontUrl': imageFrontUrl,
    };
  }
}