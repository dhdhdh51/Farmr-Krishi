import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/screens/farmer/farmer_home_screen.dart';
import 'package:krishi_connect/screens/tractor_owner/tractor_owner_home_screen.dart';
import 'package:krishi_connect/screens/tubewell_owner/tubewell_owner_home_screen.dart';
import 'package:krishi_connect/utils/constants.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({'role': role});

    final updatedUser = user.copyWith(role: role);
    authProvider.setUser(updatedUser);

    if (!context.mounted) return;

    Widget home;
    switch (role) {
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => home),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apna Role Chunein'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aap kaun hain?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Apna role select karein',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            _buildRoleButton(
              context,
              AppConstants.roleFarmer,
              'Farmer (Kisan)',
              Icons.person,
              'Tractor aur Tubewell book karein',
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildRoleButton(
              context,
              AppConstants.roleTractorOwner,
              'Tractor Owner',
              Icons.agriculture,
              'Jutayi ka kaam manage karein',
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildRoleButton(
              context,
              AppConstants.roleTubewellOwner,
              'Tubewell Owner',
              Icons.water_drop,
              'Pani supply manage karein',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String role, String title,
      IconData icon, String subtitle, Color color) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        child: InkWell(
          onTap: () => _selectRole(context, role),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
