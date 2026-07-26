import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:krishi_connect/models/job_tubewell_model.dart';
import 'package:krishi_connect/models/user_model.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/providers/rate_provider.dart';
import 'package:krishi_connect/services/firestore_service.dart';
import 'package:krishi_connect/utils/constants.dart';

class WaterSessionScreen extends StatefulWidget {
  const WaterSessionScreen({super.key});

  @override
  State<WaterSessionScreen> createState() => _WaterSessionScreenState();
}

class _WaterSessionScreenState extends State<WaterSessionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _bighaController = TextEditingController();
  String _billingMode = AppConstants.billingHourly;
  UserModel? _selectedFarmer;
  List<UserModel> _farmers = [];

  // Timer state
  bool _isRunning = false;
  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String? _activeJobId;

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

  void _startTimer() async {
    if (_selectedFarmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer select karein')),
      );
      return;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final owner = authProvider.currentUser!;

    _startTime = DateTime.now();

    final job = JobTubewellModel(
      id: '',
      tubewellId: '',
      ownerUid: owner.uid,
      ownerName: owner.name,
      farmerUid: _selectedFarmer!.uid,
      farmerName: _selectedFarmer!.name,
      billingMode: _billingMode,
      startTime: _startTime!,
      bigha: _billingMode == AppConstants.billingPerBigha
          ? double.tryParse(_bighaController.text) ?? 0
          : 0,
      status: AppConstants.statusInProgress,
    );

    _activeJobId = await _firestoreService.createTubewellJob(job);

    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _stopTimer() async {
    _timer?.cancel();

    if (_activeJobId == null) return;

    final rateProvider = Provider.of<RateProvider>(context, listen: false);
    await rateProvider.loadRates();
    await _firestoreService.completeTubewellJob(
        _activeJobId!, rateProvider.rates);

    setState(() {
      _isRunning = false;
    });

    if (mounted) {
      final hours = _elapsed.inMinutes / 60;
      final rates = rateProvider.rates;
      double price = hours * rates.pricePerHourWater;
      if (_billingMode == AppConstants.billingPerBigha) {
        price = (double.tryParse(_bighaController.text) ?? 0) *
            rates.pricePerBighaWater;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Session complete! Rs ${price.toStringAsFixed(0)}',
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  // For bigha-based (no timer, just log)
  void _logBighaSession() async {
    if (_selectedFarmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer select karein')),
      );
      return;
    }
    if (_bighaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bigha daalein')),
      );
      return;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final owner = authProvider.currentUser!;
    final rateProvider = Provider.of<RateProvider>(context, listen: false);
    await rateProvider.loadRates();
    final rates = rateProvider.rates;
    final bigha = double.parse(_bighaController.text);
    final price = bigha * rates.pricePerBighaWater;

    final job = JobTubewellModel(
      id: '',
      tubewellId: '',
      ownerUid: owner.uid,
      ownerName: owner.name,
      farmerUid: _selectedFarmer!.uid,
      farmerName: _selectedFarmer!.name,
      billingMode: AppConstants.billingPerBigha,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      bigha: bigha,
      priceCalculated: price,
      status: AppConstants.statusCompleted,
    );

    final jobId = await _firestoreService.createTubewellJob(job);
    await _firestoreService.completeTubewellJob(jobId, rates);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session logged! Rs ${price.toStringAsFixed(0)}')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bighaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rateProvider = Provider.of<RateProvider>(context);
    final rates = rateProvider.rates;

    return Scaffold(
      appBar: AppBar(title: const Text('Water Session (Pani)')),
      body: SingleChildScrollView(
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
                    const Text('Current Rates:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Per Hour: Rs ${rates.pricePerHourWater}'),
                    Text('Per Bigha: Rs ${rates.pricePerBighaWater}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Farmer selection
            const Text('Farmer select karein:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
              onChanged: _isRunning
                  ? null
                  : (val) => setState(() => _selectedFarmer = val),
            ),
            const SizedBox(height: 16),

            // Billing mode
            const Text('Billing Mode:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
              onSelectionChanged: _isRunning
                  ? null
                  : (val) => setState(() => _billingMode = val.first),
            ),
            const SizedBox(height: 24),

            // Timer mode UI
            if (_billingMode == AppConstants.billingHourly) ...[
              // Timer display
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRunning
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: _isRunning ? Colors.green : Colors.grey,
                      width: 4,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRunning
                            ? Icons.water_drop
                            : Icons.water_drop_outlined,
                        size: 32,
                        color: _isRunning ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_elapsed.inHours.toString().padLeft(2, '0')}:'
                        '${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}:'
                        '${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: _isRunning ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? 'Bijli ON' : 'Bijli OFF',
                        style: TextStyle(
                          color: _isRunning ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Start/Stop button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(
                    _isRunning ? 'Bijli OFF - Stop Timer' : 'Bijli ON - Start Timer',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            // Bigha mode UI
            if (_billingMode == AppConstants.billingPerBigha) ...[
              TextField(
                controller: _bighaController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Kitna Bigha irrigated?',
                  hintText: 'e.g., 3',
                  prefixIcon: Icon(Icons.landscape),
                  suffixText: 'Bigha',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              if (_bighaController.text.isNotEmpty)
                Text(
                  'Amount: Rs ${((double.tryParse(_bighaController.text) ?? 0) * rates.pricePerBighaWater).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logBighaSession,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Log Session',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
