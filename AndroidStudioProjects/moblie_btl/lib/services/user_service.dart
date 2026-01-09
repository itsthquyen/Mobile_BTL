
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }
}