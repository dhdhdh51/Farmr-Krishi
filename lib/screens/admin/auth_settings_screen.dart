import 'package:flutter/material.dart';
import 'package:krishi_connect/services/firestore_service.dart';

class AuthSettingsScreen extends StatefulWidget {
  const AuthSettingsScreen({super.key});

  @override
  State<AuthSettingsScreen> createState() => _AuthSettingsScreenState();
}

class _AuthSettingsScreenState extends State<AuthSettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _otpRequired = false;
  bool _otpForPhoneLogin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _firestoreService.getAuthSettings();
    setState(() {
      _otpRequired = settings['otpRequired'] ?? false;
      _otpForPhoneLogin = settings['otpForPhoneLogin'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await _firestoreService.updateAuthSettings({
      'otpRequired': _otpRequired,
      'otpForPhoneLogin': _otpForPhoneLogin,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auth settings saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OTP Verification Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Control whether OTP is required for login',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: SwitchListTile(
                      title: const Text('OTP Required for Email Login'),
                      subtitle: const Text(
                        'Jab ON hai, email login ke baad OTP verify karna hoga',
                      ),
                      value: _otpRequired,
                      onChanged: (val) => setState(() => _otpRequired = val),
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: SwitchListTile(
                      title: const Text('OTP for Phone Login'),
                      subtitle: const Text(
                        'Jab ON hai, phone login mein bhi OTP chahiye hoga',
                      ),
                      value: _otpForPhoneLogin,
                      onChanged: (val) =>
                          setState(() => _otpForPhoneLogin = val),
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
