import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/queue_token.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  // Local state
  List<QueueToken> tokens = [
    QueueToken(tokenNumber: 'A-020', serviceName: 'Birth Certificate'),
    QueueToken(tokenNumber: 'A-021', serviceName: 'Income Certificate'),
    QueueToken(tokenNumber: 'A-022', serviceName: 'Pension Services'),
    QueueToken(tokenNumber: 'A-023', serviceName: 'Residence Certificate'),
    QueueToken(tokenNumber: 'A-024', serviceName: 'Aadhaar / ID Services'),
    QueueToken(tokenNumber: 'A-025', serviceName: 'Other Citizen Services'),
  ];

  String selectedService = 'All Services';

  // Statistics
  int servedCount = 12;
  int skippedCount = 1;

  List<String> get availableServices => [
        'All Services',
        'Birth Certificate',
        'Income Certificate',
        'Pension Services',
        'Residence Certificate',
        'Aadhaar / ID Services',
        'Other Citizen Services',
      ];

  List<QueueToken> get waitingTokens {
    return tokens.where((t) => t.status == TokenStatus.waiting && (selectedService == 'All Services' || t.serviceName == selectedService)).toList();
  }

  QueueToken? get currentlyServing {
    try {
      return tokens.firstWhere((t) => t.status == TokenStatus.serving);
    } catch (e) {
      return null;
    }
  }

  int get waitingCount => tokens.where((t) => t.status == TokenStatus.waiting).length;
  int get servingCount => currentlyServing != null ? 1 : 0;

  void _callNextToken() {
    if (currentlyServing != null) return; // Must finish current token first

    final waiting = waitingTokens;
    if (waiting.isNotEmpty) {
      setState(() {
        waiting.first.status = TokenStatus.serving;
      });
    }
  }

  void _markAsServed() {
    final current = currentlyServing;
    if (current != null) {
      setState(() {
        current.status = TokenStatus.served;
        servedCount++;
      });
    }
  }

  void _skipToken() {
    final current = currentlyServing;
    if (current != null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Skip Token'),
            content: Text('Skip token ${current.tokenNumber}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    current.status = TokenStatus.skipped;
                    skippedCount++;
                  });
                },
                child: const Text('Skip Token'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to Home',
          ),
        ],
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          _buildCurrentlyServingCard(),
          const SizedBox(height: 16),
          _buildServiceFilter(),
          const SizedBox(height: 16),
          _buildWaitingQueueSection(),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCurrentlyServingCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildServiceFilter(),
                          const SizedBox(height: 16),
                          Expanded(child: _buildWaitingQueueSection()),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Municipal Service Center',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        SizedBox(height: 4),
        Text(
          'Manage the queue and assist citizens.',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Waiting', waitingCount.toString(), AppTheme.primaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Serving', servingCount.toString(), AppTheme.secondaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Served', servedCount.toString(), AppTheme.secondaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatCard('Skipped', skippedCount.toString(), Colors.red)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentlyServingCard() {
    final current = currentlyServing;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.secondaryColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('CURRENTLY SERVING', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            if (current != null) ...[
              Text(current.tokenNumber, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.primaryColor)),
              const SizedBox(height: 8),
              Text('Service: ${current.serviceName}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.secondaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Text('Status: Serving', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _skipToken,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                    child: const Text('Skip Token'),
                  ),
                  ElevatedButton(
                    onPressed: _markAsServed,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                    child: const Text('Mark as Served'),
                  ),
                ],
              ),
            ] else ...[
              const Icon(Icons.person_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No token is currently being served.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: waitingTokens.isNotEmpty ? _callNextToken : null,
                  icon: const Icon(Icons.campaign),
                  label: const Text('Call Next Token'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServiceFilter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Filter by Service',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedService,
          isExpanded: true,
          items: availableServices.map((String service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedService = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildWaitingQueueSection() {
    final waiting = waitingTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waiting Queue',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 16),
        if (waiting.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No citizens are currently waiting.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: waiting.length,
              itemBuilder: (context, index) {
                final token = waiting[index];
                final isNext = index == 0;

                return Card(
                  elevation: isNext ? 3 : 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isNext ? AppTheme.accentColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isNext ? AppTheme.accentColor.withValues(alpha: 0.2) : AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          color: isNext ? AppTheme.accentColor : AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          token.tokenNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (isNext) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NEXT',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]
                      ],
                    ),
                    subtitle: Text(token.serviceName),
                    trailing: const Text('Waiting', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
