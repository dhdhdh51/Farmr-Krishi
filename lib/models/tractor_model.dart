import 'package:cloud_firestore/cloud_firestore.dart';

class TractorModel {
  final String id;
  final String ownerUid;
  final String ownerName;
  final GeoPoint? currentLocation;
  final String status; // available, busy
  final bool isActive;

  TractorModel({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    this.currentLocation,
    this.status = 'available',
    this.isActive = true,
  });

  factory TractorModel.fromMap(Map<String, dynamic> map, String id) {
    return TractorModel(
      id: id,
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      currentLocation: map['currentLocation'] as GeoPoint?,
      status: map['status'] ?? 'available',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'currentLocation': currentLocation,
      'status': status,
      'isActive': isActive,
    };
  }
}
