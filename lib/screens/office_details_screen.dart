import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/queue_service.dart';
import 'token_screen.dart';

class OfficeDetailsScreen extends StatelessWidget {
  final String officeName;
  final String location;
  final String officeId;

  const OfficeDetailsScreen({
    super.key,
    required this.officeName,
    required this.location,
    required this.officeId,
  });

  @override
  Widget build(BuildContext context) {
    final services = [
      'Aadhaar / ID Services',
      'Birth Certificate',
      'Income Certificate',
      'Residence Certificate',
      'Pension Services',
      'Other Citizen Services',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOfficeCard(),
            const SizedBox(height: 32),
            const Text(
              'Available Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...services.map((service) => _buildServiceCard(context, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business, color: AppTheme.primaryColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    officeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: $officeId',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String serviceName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          serviceName,
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.secondaryColor),
        onTap: () {
          _showConfirmationDialog(context, serviceName);
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Service'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Office:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(officeName, style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              const Text('Selected Service:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(serviceName, style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                final token = QueueService().generateCitizenToken(serviceName);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TokenScreen(
                      serviceName: serviceName,
                      officeName: officeName,
                      tokenNumber: token.tokenNumber,
                    ),
                  ),
                );
              },
              child: const Text('Get Digital Token'),
            ),
          ],
        );
      },
    );
  }
}
