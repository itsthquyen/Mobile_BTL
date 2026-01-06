class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String avatarUrl;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
  });

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}
