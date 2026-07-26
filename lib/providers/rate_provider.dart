import 'package:flutter/material.dart';
import 'package:krishi_connect/models/rate_model.dart';
import 'package:krishi_connect/services/firestore_service.dart';

class RateProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  RateModel _rates = RateModel();
  bool _isLoading = false;

  RateModel get rates => _rates;
  bool get isLoading => _isLoading;

  Future<void> loadRates() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rates = await _firestoreService.getRates();
    } catch (e) {
      // Use default rates if not found
      _rates = RateModel();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRates(RateModel newRates) async {
    _isLoading = true;
    notifyListeners();

    await _firestoreService.updateRates(newRates);
    _rates = newRates;

    _isLoading = false;
    notifyListeners();
  }
}
