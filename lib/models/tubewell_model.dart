import 'package:cloud_firestore/cloud_firestore.dart';

class TubewellModel {
  final String id;
  final String ownerUid;
  final String ownerName;
  final GeoPoint? location;
  final String billingMode; // hourly, per_bigha
  final bool isActive;

  TubewellModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    this.location,
    this.billingMode = 'hourly',
    this.isActive = true,
  });

  factory TubewellModel.fromMap(Map<String, dynamic> map, String id) {
    return TubewellModel(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      location: map['location'] as GeoPoint?,
      billingMode: map['billingMode'] ?? 'hourly',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'location': location,
      'billingMode': billingMode,
      'isActive': isActive,
    };
  }
}
