import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/connection_model.dart';
import 'package:krishi_connect/models/job_tubewell_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class BookTubewellScreen extends StatefulWidget {
  const BookTubewellScreen({super.key});

  @override
  State<BookTubewellScreen> createState() => _BookTubewellScreenState();
}

class _BookTubewellScreenState extends State<BookTubewellScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _bighaController = TextEditingController();
  String _billingMode = AppConstants.billingHourly;
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
          .where((c) => c.ownerRole == AppConstants.roleTubewellOwner)
          .toList();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _bookTubewell() async {
    if (_selectedConnection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle tubewell owner select karein')),
      );
      return;
    }

    if (_billingMode == AppConstants.billingPerBigha &&
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

    final bigha = _billingMode == AppConstants.billingPerBigha
        ? double.parse(_bighaController.text)
        : 0.0;

    final job = JobTubewellModel(
      id: '',
      tubewellId: '', // Will be assigned by owner
      ownerUid: _selectedConnection!.ownerUid,
      ownerName: _selectedConnection!.ownerName,
      farmerUid: farmer.uid,
      farmerName: farmer.name,
      billingMode: _billingMode,
      startTime: DateTime.now(),
      bigha: bigha,
      status: AppConstants.statusPending,
    );

    await _firestoreService.createTubewellJob(job);

    setState(() => _isBooking = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _billingMode == AppConstants.billingHourly
                ? 'Booking ho gayi! Timer owner start karega'
                : 'Booking ho gayi! $bigha bigha ke liye',
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
      appBar: AppBar(title: const Text('Tubewell Book Karein (Pani)')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rate info
                  Card(
                    color: const Color(0xFFE3F2FD),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Rates:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Per Hour: Rs ${rates.pricePerHourWater}'),
                          Text('Per Bigha: Rs ${rates.pricePerBighaWater}/bigha'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Select tubewell owner
                  const Text(
                    'Tubewell Owner select karein:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_connections.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Koi tubewell owner connected nahi hai.\nPehle Search se connect karein.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<ConnectionModel>(
                      decoration: const InputDecoration(
                        labelText: 'Owner',
                        prefixIcon: Icon(Icons.water_drop),
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

                  // Billing mode
                  const Text(
                    'Billing Mode chunein:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: AppConstants.billingHourly,
                        label: Text('Hourly (Timer)'),
                        icon: Icon(Icons.timer),
                      ),
                      ButtonSegment(
                        value: AppConstants.billingPerBigha,
                        label: Text('Per Bigha'),
                        icon: Icon(Icons.landscape),
                      ),
                    ],
                    selected: {_billingMode},
                    onSelectionChanged: (val) =>
                        setState(() => _billingMode = val.first),
                  ),
                  const SizedBox(height: 16),

                  if (_billingMode == AppConstants.billingHourly)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Timer tubewell owner start/stop karega.\nBijli ON = timer start, Bijli OFF = timer stop.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_billingMode == AppConstants.billingPerBigha) ...[
                    TextField(
                      controller: _bighaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Kitna Bigha?',
                        hintText: 'e.g., 3',
                        prefixIcon: Icon(Icons.landscape),
                        suffixText: 'Bigha',
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_bighaController.text.isNotEmpty)
                      Text(
                        'Estimated: Rs ${((double.tryParse(_bighaController.text) ?? 0) * rates.pricePerBighaWater).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isBooking ? null : _bookTubewell,
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
