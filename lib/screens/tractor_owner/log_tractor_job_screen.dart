import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/job_tractor_model.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class LogTractorJobScreen extends StatefulWidget {
  const LogTractorJobScreen({super.key});

  @override
  State<LogTractorJobScreen> createState() => _LogTractorJobScreenState();
}

class _LogTractorJobScreenState extends State<LogTractorJobScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _bighaController = TextEditingController();
  final _farmerSearchController = TextEditingController();
  String _pricingMode = AppConstants.pricingFlat;
  List<UserModel> _farmers = [];
  UserModel? _selectedFarmer;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
    Provider.of<RateProvider>(context, listen: false).loadRates();
  }

  Future<void> _loadFarmers() async {
    _farmers = await _firestoreService.getUsersByRole(AppConstants.roleFarmer);
    setState(() {});
  }

  Future<void> _logJob() async {
    if (_selectedFarmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer select karein')),
      );
      return;
    }

    if (_pricingMode == AppConstants.pricingPerBigha &&
        _bighaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bigha daalein')),
      );
      return;
    }

    setState(() => _isLogging = true);

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final owner = authProvider.currentUser!;
    final rateProvider = Provider.of<RateProvider>(context, listen: false);
    final rates = rateProvider.rates;

    final bigha = _pricingMode == AppConstants.pricingPerBigha
        ? double.parse(_bighaController.text)
        : 0.0;

    double price = 0;
    if (_pricingMode == AppConstants.pricingFlat) {
      price = rates.pricePerJutayi;
    } else {
      price = bigha * rates.pricePerBighaTractor;
    }

    final job = JobTractorModel(
      id: '',
      tractorId: '',
      ownerUid: owner.uid,
      ownerName: owner.name,
      farmerUid: _selectedFarmer!.uid,
      farmerName: _selectedFarmer!.name,
      pricingMode: _pricingMode,
      bigha: bigha,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      priceCalculated: price,
      status: AppConstants.statusCompleted,
    );

    final jobId = await _firestoreService.createTractorJob(job);

    // Auto-create payment entry
    await _firestoreService.completeTractorJob(jobId, rates);

    setState(() => _isLogging = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job logged! Rs ${price.toStringAsFixed(0)}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _bighaController.dispose();
    _farmerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rateProvider = Provider.of<RateProvider>(context);
    final rates = rateProvider.rates;

    return Scaffold(
      appBar: AppBar(title: const Text('Log Tractor Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer selection
            const Text(
              'Farmer select karein:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserModel>(
              decoration: const InputDecoration(
                labelText: 'Farmer',
                prefixIcon: Icon(Icons.person),
              ),
              items: _farmers
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text('${f.name} (${f.phone})'),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedFarmer = val),
            ),
            const SizedBox(height: 24),

            // Pricing mode (as selected by farmer/at logging)
            const Text(
              'Pricing Mode:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: AppConstants.pricingFlat,
                  label: Text('Flat (Per Jutayi)'),
                  icon: Icon(Icons.payments),
                ),
                ButtonSegment(
                  value: AppConstants.pricingPerBigha,
                  label: Text('Per Bigha'),
                  icon: Icon(Icons.landscape),
                ),
              ],
              selected: {_pricingMode},
              onSelectionChanged: (val) =>
                  setState(() => _pricingMode = val.first),
            ),
            const SizedBox(height: 16),

            if (_pricingMode == AppConstants.pricingPerBigha) ...[
              TextField(
                controller: _bighaController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Bigha (Area ploughed)',
                  hintText: 'e.g., 2.5',
                  prefixIcon: Icon(Icons.landscape),
                  suffixText: 'Bigha',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
            ],

            // Price preview
            Card(
              color: const Color(0xFFE8F5E9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text(
                      _pricingMode == AppConstants.pricingFlat
                          ? 'Amount: Rs ${rates.pricePerJutayi.toStringAsFixed(0)}'
                          : 'Amount: Rs ${((double.tryParse(_bighaController.text) ?? 0) * rates.pricePerBighaTractor).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLogging ? null : _logJob,
                icon: _isLogging
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text(
                  'Log Complete Job',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
