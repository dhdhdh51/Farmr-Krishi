class RateModel {
  final double pricePerJutayi;
  final double pricePerBighaTractor;
  final double pricePerHourWater;
  final double pricePerBighaWater;

  RateModel({
    this.pricePerJutayi = 0,
    this.pricePerBighaTractor = 0,
    this.pricePerHourWater = 0,
    this.pricePerBighaWater = 0,
  });

  factory RateModel.fromMap(Map<String, dynamic> map) {
    return RateModel(
      pricePerJutayi: (map['pricePerJutayi'] ?? 0).toDouble(),
      pricePerBighaTractor: (map['pricePerBighaTractor'] ?? 0).toDouble(),
      pricePerHourWater: (map['pricePerHourWater'] ?? 0).toDouble(),
      pricePerBighaWater: (map['pricePerBighaWater'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pricePerJutayi': pricePerJutayi,
      'pricePerBighaTractor': pricePerBighaTractor,
      'pricePerHourWater': pricePerHourWater,
      'pricePerBighaWater': pricePerBighaWater,
    };
  }
}
