import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String? email;
  final String role; // farmer, tractor_owner, tubewell_owner, admin
  final GeoPoint? location;
  final String? pin; // 4-6 digit PIN for phone login
  final DateTime createdAt;
  final bool isApproved; // For tractor/tubewell owners, admin approves

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.location,
    this.pin,
    required this.createdAt,
    this.isApproved = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      role: map['role'] ?? '',
      location: map['location'] as GeoPoint?,
      pin: map['pin'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isApproved: map['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'location': location,
      'pin': pin,
      'createdAt': Timestamp.fromDate(createdAt),
      'isApproved': isApproved,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? role,
    GeoPoint? location,
    String? pin,
    bool? isApproved,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      location: location ?? this.location,
      pin: pin ?? this.pin,
      createdAt: createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
