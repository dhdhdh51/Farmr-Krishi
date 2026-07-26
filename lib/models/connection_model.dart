import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionModel {
  final String id;
  final String farmerUid;
  final String ownerUid;
  final String ownerRole; // tractor_owner, tubewell_owner
  final String ownerName;
  final String farmerName;
  final DateTime connectedAt;

  ConnectionModel({
    required this.id,
    required this.farmerUid,
    required this.ownerUid,
    required this.ownerRole,
    required this.ownerName,
    required this.farmerName,
    required this.connectedAt,
  });

  factory ConnectionModel.fromMap(Map<String, dynamic> map, String id) {
    return ConnectionModel(
      id: id,
      farmerUid: map['farmerUid'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerRole: map['ownerRole'] ?? '',
      ownerName: map['ownerName'] ?? '',
      farmerName: map['farmerName'] ?? '',
      connectedAt: (map['connectedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerUid': farmerUid,
      'ownerUid': ownerUid,
      'ownerRole': ownerRole,
      'ownerName': ownerName,
      'farmerName': farmerName,
      'connectedAt': Timestamp.fromDate(connectedAt),
    };
  }
}
