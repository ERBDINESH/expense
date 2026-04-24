import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String imageUrl;
  final bool isActive;
  final bool isEmailVerified;
  final String username;
  final String? password;
  final DateTime? createdAt;
  final String currency;

  UserModel({
    required this.email,
    required this.imageUrl,
    required this.isActive,
    required this.isEmailVerified,
    required this.username,
    this.password,
    this.createdAt,
    this.currency = 'INR',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isactive'] ?? false,
      isEmailVerified: map['isemailverified'] ?? false,
      username: map['username'] ?? '',
      password: map['password'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      currency: map['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'imageUrl': imageUrl,
      'isactive': isActive,
      'isemailverified': isEmailVerified,
      'username': username,
      'password': password,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'currency': currency,
    };
  }
}
