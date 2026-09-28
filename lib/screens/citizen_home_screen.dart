import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/queue_token.dart';
import 'qr_scanner_screen.dart';
import 'staff_dashboard_screen.dart';
import 'queue_status_screen.dart';
import '../services/queue_service.dart';

class CitizenHomeScreen extends StatelessWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join government service queues digitally.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            _buildScanAction(context),
            const SizedBox(height: 32),
            const Text(
              'My Current Token',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: QueueService(),
              builder: (context, child) {
                final token = QueueService().currentCitizenToken;
                if (token == null) {
                  return _buildEmptyTokenState();
                }
                return _buildActiveTokenState(context, token);
              },
            ),
            const SizedBox(height: 48),
            _buildStaffAccess(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffAccess(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffDashboardScreen()),
          );
        },
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('Staff Dashboard (Demo)'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildScanAction(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QrScannerScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan Office QR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap here to scan QR at the office',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTokenState(BuildContext context, QueueToken token) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(24),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          radius: 30,
          child: const Icon(Icons.receipt, color: AppTheme.primaryColor, size: 30),
        ),
        title: Text(
          token.tokenNumber,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
        ),
        subtitle: Text('Service: ${token.serviceName}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QueueStatusScreen(
                tokenNumber: token.tokenNumber,
                nowServing: QueueService().currentlyServing?.tokenNumber ?? '--',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTokenState() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No active token',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan an office QR code to join a queue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
