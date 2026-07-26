import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:krishi_connect/providers/auth_provider.dart';
import 'package:krishi_connect/screens/admin/pricing_screen.dart';
import 'package:krishi_connect/screens/admin/resource_management_screen.dart';
import 'package:krishi_connect/screens/admin/revenue_report_screen.dart';
import 'package:krishi_connect/screens/admin/all_logs_screen.dart';
import 'package:krishi_connect/screens/admin/auth_settings_screen.dart';
import 'package:krishi_connect/screens/admin/user_management_screen.dart';
import 'package:krishi_connect/screens/auth/login_screen.dart';
import 'package:krishi_connect/screens/common/profile_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AppAuthProvider>(context, listen: false)
                  .logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildDashboardCard(
              context,
              'Pricing / Rates',
              Icons.monetization_on,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PricingScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Resources',
              Icons.build,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ResourceManagementScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Revenue / Kharcha',
              Icons.bar_chart,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RevenueReportScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'All Logs',
              Icons.list_alt,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllLogsScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'User Management',
              Icons.group,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const UserManagementScreen()),
              ),
            ),
            _buildDashboardCard(
              context,
              'Auth Settings',
              Icons.security,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthSettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
