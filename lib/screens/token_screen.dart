import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/queue_service.dart';
import 'queue_status_screen.dart';

class TokenScreen extends StatelessWidget {
  final String serviceName;
  final String officeName;
  final String tokenNumber;

  const TokenScreen({
    super.key,
    required this.serviceName,
    required this.officeName,
    required this.tokenNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Token'),
        automaticallyImplyLeading: false, // Prevent going back to confirmation directly easily
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ListenableBuilder(
          listenable: QueueService(),
          builder: (context, _) {
            final nowServing = QueueService().currentlyServing?.tokenNumber ?? '--';
            final currentToken = QueueService().currentCitizenToken;
            final peopleAhead = currentToken != null ? QueueService().getPeopleAhead(currentToken) : 0;
            final estWait = peopleAhead * 5;

            return Column(
              children: [
                _buildTokenCard(tokenNumber, nowServing, peopleAhead, estWait),
                const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QueueStatusScreen(
                        tokenNumber: tokenNumber,
                        nowServing: nowServing,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.remove_red_eye),
                label: const Text('View Queue Status'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildTokenCard(String tokenNumber, String nowServing, int peopleAhead, int estWait) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Colors.white, AppTheme.backgroundColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR TOKEN',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tokenNumber,
                    style: const TextStyle(color: AppTheme.accentColor, fontSize: 64, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Service', serviceName),
                  const Divider(height: 24),
                  _buildInfoRow('Office', officeName),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniStat('Now Serving', nowServing, AppTheme.primaryColor),
                      _buildMiniStat('People Ahead', '$peopleAhead', AppTheme.secondaryColor),
                      _buildMiniStat('Est. Wait', '$estWait min', AppTheme.accentColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
