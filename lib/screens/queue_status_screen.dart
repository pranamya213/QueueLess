import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/queue_token.dart';
import '../services/queue_service.dart';

class QueueStatusScreen extends StatelessWidget {
  final String tokenNumber;
  final String nowServing;

  const QueueStatusScreen({
    super.key,
    required this.tokenNumber,
    required this.nowServing,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: QueueService(),
      builder: (context, _) {
        final currentToken = QueueService().currentCitizenToken;
        final currentServing = QueueService().currentlyServing;
        final actualNowServing = currentServing?.tokenNumber ?? nowServing;
        final peopleAhead = currentToken != null ? QueueService().getPeopleAhead(currentToken) : 0;
        final estWait = peopleAhead * 5;
        final statusText = currentToken?.status == TokenStatus.serving ? 'Serving' : 'Waiting';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Queue Status'),
            actions: [
              _buildNotificationIcon(context),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStatusHeader(statusText),
                const SizedBox(height: 32),
                if (QueueService().notifications.isNotEmpty) ...[
                  _buildLatestNotification(),
                  const SizedBox(height: 32),
                ],
                _buildProgressIndicator(),
                const SizedBox(height: 48),
                _buildStatsGrid(actualNowServing, peopleAhead, estWait),
                const SizedBox(height: 48),
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
          ),
        ),
      );
    });
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final unreadCount = QueueService().unreadNotificationsCount;
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _showNotificationsDialog(context),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    QueueService().markAllNotificationsRead();
    showDialog(
      context: context,
      builder: (context) {
        final notifications = QueueService().notifications;
        return AlertDialog(
          title: const Text('Notifications'),
          content: SizedBox(
            width: double.maxFinite,
            child: notifications.isEmpty
                ? const Text('No notifications.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return ListTile(
                        leading: const Icon(Icons.notifications, color: AppTheme.accentColor),
                        title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(n.message),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLatestNotification() {
    final latest = QueueService().notifications.first;
    final isServing = QueueService().currentCitizenToken?.status == TokenStatus.serving;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isServing ? AppTheme.secondaryColor.withValues(alpha: 0.1) : AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isServing ? AppTheme.secondaryColor : AppTheme.accentColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: isServing ? AppTheme.secondaryColor : AppTheme.accentColor),
              const SizedBox(width: 8),
              const Text('Queue Update', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(latest.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isServing ? AppTheme.secondaryColor : AppTheme.primaryColor)),
          const SizedBox(height: 4),
          Text(latest.message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(String statusText) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(statusText, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Your Token', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                const SizedBox(height: 4),
                Text(tokenNumber, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width: 150, // Simulated progress
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Almost there! Please stay near the waiting area.',
          style: TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(String nowServingValue, int peopleAhead, int estWait) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Now Serving', nowServingValue, Icons.people, AppTheme.primaryLight)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('People Ahead', '$peopleAhead', Icons.format_list_numbered, AppTheme.secondaryColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Est. Wait', '$estWait min', Icons.timer, AppTheme.accentColor)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
