import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/screens/farmer/farmer_home_screen.dart';
import 'package:krishi_connect/screens/tractor_owner/tractor_owner_home_screen.dart';
import 'package:krishi_connect/screens/tubewell_owner/tubewell_owner_home_screen.dart';
import 'package:krishi_connect/utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  String _selectedRole = AppConstants.roleFarmer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Naam aur phone number zaroori hai')),
      );
      return;
    }

    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kam se kam 4 digit ka hona chahiye')),
      );
      return;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final success = await authProvider.signup(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text.trim()
          : _pinController.text.trim(),
      pin: _pinController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      Widget home;
      switch (_selectedRole) {
        case AppConstants.roleFarmer:
          home = const FarmerHomeScreen();
          break;
        case AppConstants.roleTractorOwner:
          home = const TractorOwnerHomeScreen();
          break;
        case AppConstants.roleTubewellOwner:
          home = const TubewellOwnerHomeScreen();
          break;
        default:
          home = const FarmerHomeScreen();
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => home),
        (route) => false,
      );
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naya Account Banayein'),
      ),
      body: Consumer<AppAuthProvider>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aapka Role chunein:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildRoleCard(
                  AppConstants.roleFarmer,
                  'Farmer (Kisan)',
                  Icons.person,
                  'Tractor aur Tubewell book karein',
                ),
                _buildRoleCard(
                  AppConstants.roleTractorOwner,
                  'Tractor Owner',
                  Icons.agriculture,
                  'Jutayi ka kaam manage karein',
                ),
                _buildRoleCard(
                  AppConstants.roleTubewellOwner,
                  'Tubewell Owner',
                  Icons.water_drop,
                  'Pani supply manage karein',
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Naam (Name)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixIcon: Icon(Icons.phone),
                    prefixText: '+91 ',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'PIN (4-6 digit)',
                    helperText: 'Phone login ke liye PIN set karein',
                    prefixIcon: Icon(Icons.pin),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password (optional - for email login)',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _signup,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Account Banayein',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(
      String role, String title, IconData icon, String subtitle) {
    final isSelected = _selectedRole == role;
    return Card(
      color: isSelected ? const Color(0xFFE8F5E9) : null,
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF2E7D32) : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF2E7D32))
            : null,
        onTap: () => setState(() => _selectedRole = role),
      ),
    );
  }
}
