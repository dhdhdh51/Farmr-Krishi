import 'package:cloud_firestore/cloud_firestore.dart';

class JobTubewellModel {
  final String id;
  final String tubewellId;
  final String ownerUid;
  final String ownerName;
  final String farmerUid;
  final String farmerName;
  final String billingMode; // hourly, per_bigha
  final DateTime startTime;
  final DateTime? endTime;
  final double totalMinutes;
  final double bigha;
  final double priceCalculated;
  final String status; // pending, in_progress, completed, cancelled

  JobTubewellModel({
    required this.id,
    required this.tubewellId,
    required this.ownerUid,
    required this.ownerName,
    required this.farmerUid,
    required this.farmerName,
    required this.billingMode,
    required this.startTime,
    this.endTime,
    this.totalMinutes = 0,
    this.bigha = 0,
    this.priceCalculated = 0,
    this.status = 'pending',
  });

  factory JobTubewellModel.fromMap(Map<String, dynamic> map, String id) {
    return JobTubewellModel(
      id: id,
      tubewellId: map['tubewellId'] ?? '',
      ownerUid: map['ownerUid'] ?? '',
      ownerName: map['ownerName'] ?? '',
      farmerUid: map['farmerUid'] ?? '',
      farmerName: map['farmerName'] ?? '',
      billingMode: map['billingMode'] ?? 'hourly',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      totalMinutes: (map['totalMinutes'] ?? 0).toDouble(),
      bigha: (map['bigha'] ?? 0).toDouble(),
      priceCalculated: (map['priceCalculated'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tubewellId': tubewellId,
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'farmerUid': farmerUid,
      'farmerName': farmerName,
      'billingMode': billingMode,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'totalMinutes': totalMinutes,
      'bigha': bigha,
      'priceCalculated': priceCalculated,
      'status': status,
    };
  }

  JobTubewellModel copyWith({
    DateTime? endTime,
    double? totalMinutes,
    double? bigha,
    double? priceCalculated,
    String? status,
  }) {
    return JobTubewellModel(
      id: id,
      tubewellId: tubewellId,
      ownerUid: ownerUid,
      ownerName: ownerName,
      farmerUid: farmerUid,
      farmerName: farmerName,
      billingMode: billingMode,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      bigha: bigha ?? this.bigha,
      priceCalculated: priceCalculated ?? this.priceCalculated,
      status: status ?? this.status,
    );
  }
}
