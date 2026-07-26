import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/screens/auth/login_screen.dart';
import 'package:krishi_connect/screens/role_selection_screen.dart';
import 'package:krishi_connect/screens/farmer/farmer_home_screen.dart';
import 'package:krishi_connect/screens/tractor_owner/tractor_owner_home_screen.dart';
import 'package:krishi_connect/screens/tubewell_owner/tubewell_owner_home_screen.dart';
import 'package:krishi_connect/screens/admin/admin_dashboard_screen.dart';
import 'package:krishi_connect/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    await authProvider.initializeUser();

    if (!mounted) return;

    if (authProvider.currentUser == null) {
      _navigate(const LoginScreen());
    } else {
      _navigateToHome(authProvider.currentUser!.role);
    }
  }

  void _navigateToHome(String role) {
    Widget home;
    switch (role) {
      case AppConstants.roleAdmin:
        home = const AdminDashboardScreen();
        break;
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
        home = const RoleSelectionScreen();
    }
    _navigate(home);
  }

  void _navigate(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.agriculture,
                size: 80,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Krishi Connect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kisan • Tractor • Tubewell',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
