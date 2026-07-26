import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/models/rate_model.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _jutayiController = TextEditingController();
  final _bighaTractorController = TextEditingController();
  final _hourWaterController = TextEditingController();
  final _bighaWaterController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    final rateProvider = Provider.of<RateProvider>(context, listen: false);
    await rateProvider.loadRates();
    final rates = rateProvider.rates;
    _jutayiController.text = rates.pricePerJutayi.toString();
    _bighaTractorController.text = rates.pricePerBighaTractor.toString();
    _hourWaterController.text = rates.pricePerHourWater.toString();
    _bighaWaterController.text = rates.pricePerBighaWater.toString();
  }

  Future<void> _saveRates() async {
    setState(() => _isLoading = true);
    final rateProvider = Provider.of<RateProvider>(context, listen: false);
    final newRates = RateModel(
      pricePerJutayi: double.tryParse(_jutayiController.text) ?? 0,
      pricePerBighaTractor: double.tryParse(_bighaTractorController.text) ?? 0,
      pricePerHourWater: double.tryParse(_hourWaterController.text) ?? 0,
      pricePerBighaWater: double.tryParse(_bighaWaterController.text) ?? 0,
    );
    await rateProvider.updateRates(newRates);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rates updated successfully!')),
      );
    }
  }

  @override
  void dispose() {
    _jutayiController.dispose();
    _bighaTractorController.dispose();
    _hourWaterController.dispose();
    _bighaWaterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing / Rates')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tractor Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRateField(
              controller: _jutayiController,
              label: 'Price per Jutayi (Flat) - Rs',
              hint: 'e.g., 500',
              icon: Icons.agriculture,
            ),
            const SizedBox(height: 12),
            _buildRateField(
              controller: _bighaTractorController,
              label: 'Price per Bigha (Tractor) - Rs',
              hint: 'e.g., 200',
              icon: Icons.landscape,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Tubewell / Pani Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRateField(
              controller: _hourWaterController,
              label: 'Price per Hour (Water) - Rs',
              hint: 'e.g., 100',
              icon: Icons.access_time,
            ),
            const SizedBox(height: 12),
            _buildRateField(
              controller: _bighaWaterController,
              label: 'Price per Bigha (Water) - Rs',
              hint: 'e.g., 150',
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveRates,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('Save Rates'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: 'Rs ',
      ),
    );
  }
}
