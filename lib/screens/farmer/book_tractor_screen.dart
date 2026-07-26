import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/connection_model.dart';
import 'package:krishi_connect/models/job_tractor_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class BookTractorScreen extends StatefulWidget {
  const BookTractorScreen({super.key});

  @override
  State<BookTractorScreen> createState() => _BookTractorScreenState();
}

class _BookTractorScreenState extends State<BookTractorScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _bighaController = TextEditingController();
  String _pricingMode = AppConstants.pricingFlat;
  ConnectionModel? _selectedConnection;
  List<ConnectionModel> _connections = [];
  bool _isLoading = true;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadConnections();
    Provider.of<RateProvider>(context, listen: false).loadRates();
  }

  Future<void> _loadConnections() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      final all = await _firestoreService.getConnectionsForFarmer(user.uid);
      _connections = all
          .where((c) => c.ownerRole == AppConstants.roleTractorOwner)
          .toList();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _bookTractor() async {
    if (_selectedConnection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle tractor owner select karein')),
      );
      return;
    }

    if (_pricingMode == AppConstants.pricingPerBigha &&
        (_bighaController.text.isEmpty ||
            double.tryParse(_bighaController.text) == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bigha amount daalein')),
      );
      return;
    }

    setState(() => _isBooking = true);

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final farmer = authProvider.currentUser!;
    final rateProvider = Provider.of<RateProvider>(context, listen: false);
    final rates = rateProvider.rates;

    final bigha = _pricingMode == AppConstants.pricingPerBigha
        ? double.parse(_bighaController.text)
        : 0.0;

    // Calculate estimated price
    double estimatedPrice = 0;
    if (_pricingMode == AppConstants.pricingFlat) {
      estimatedPrice = rates.pricePerJutayi;
    } else {
      estimatedPrice = bigha * rates.pricePerBighaTractor;
    }

    final job = JobTractorModel(
      id: '',
      tractorId: '', // Will be assigned by owner
      ownerUid: _selectedConnection!.ownerUid,
      ownerName: _selectedConnection!.ownerName,
      farmerUid: farmer.uid,
      farmerName: farmer.name,
      pricingMode: _pricingMode,
      bigha: bigha,
      startTime: DateTime.now(),
      priceCalculated: estimatedPrice,
      status: AppConstants.statusPending,
    );

    await _firestoreService.createTractorJob(job);

    setState(() => _isBooking = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ho gayi! Estimated: Rs ${estimatedPrice.toStringAsFixed(0)}',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _bighaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rateProvider = Provider.of<RateProvider>(context);
    final rates = rateProvider.rates;

    return Scaffold(
      appBar: AppBar(title: const Text('Tractor Book Karein (Jutayi)')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rate info
                  Card(
                    color: const Color(0xFFFFF3E0),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Rates:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Flat per Jutayi: Rs ${rates.pricePerJutayi}'),
                          Text(
                              'Per Bigha: Rs ${rates.pricePerBighaTractor}/bigha'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Select tractor owner
                  const Text(
                    'Tractor Owner select karein:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_connections.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Koi tractor owner connected nahi hai.\nPehle Search se connect karein.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<ConnectionModel>(
                      decoration: const InputDecoration(
                        labelText: 'Owner',
                        prefixIcon: Icon(Icons.agriculture),
                      ),
                      value: _selectedConnection,
                      items: _connections
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.ownerName),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedConnection = val),
                    ),
                  const SizedBox(height: 24),

                  // Pricing mode
                  const Text(
                    'Pricing Mode chunein:',
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

                  // Bigha input (if per bigha)
                  if (_pricingMode == AppConstants.pricingPerBigha) ...[
                    TextField(
                      controller: _bighaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Kitna Bigha?',
                        hintText: 'e.g., 2.5',
                        prefixIcon: Icon(Icons.landscape),
                        suffixText: 'Bigha',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_bighaController.text.isNotEmpty)
                      Text(
                        'Estimated: Rs ${((double.tryParse(_bighaController.text) ?? 0) * rates.pricePerBighaTractor).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],

                  if (_pricingMode == AppConstants.pricingFlat)
                    Text(
                      'Flat Rate: Rs ${rates.pricePerJutayi.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Book button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isBooking ? null : _bookTractor,
                      icon: _isBooking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle),
                      label: const Text(
                        'Book Karein',
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
