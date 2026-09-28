import 'package:flutter/foundation.dart';
import '../models/queue_token.dart';
import '../models/queue_notification.dart';

class QueueService extends ChangeNotifier {
  static final QueueService _instance = QueueService._internal();
  factory QueueService() => _instance;

  QueueService._internal() {
    _initializeDemoData();
  }

  List<QueueToken> tokens = [];
  QueueToken? currentCitizenToken;
  List<QueueNotification> notifications = [];
  final Set<int> _triggeredDistances = {};

  int servedCount = 12;
  int skippedCount = 1;

  void _initializeDemoData() {
    tokens = [
      QueueToken(tokenNumber: 'A-020', serviceName: 'Birth Certificate'),
      QueueToken(tokenNumber: 'A-021', serviceName: 'Income Certificate'),
      QueueToken(tokenNumber: 'A-022', serviceName: 'Pension Services'),
      QueueToken(tokenNumber: 'A-023', serviceName: 'Residence Certificate'),
      QueueToken(tokenNumber: 'A-024', serviceName: 'Aadhaar / ID Services'),
      QueueToken(tokenNumber: 'A-025', serviceName: 'Other Citizen Services'),
    ];
  }

  // --- Citizen Methods ---

  QueueToken generateCitizenToken(String serviceName) {
    // Generate next token number based on last demo token
    int lastNumber = int.parse(tokens.last.tokenNumber.split('-')[1]);
    String newTokenNumber = 'A-0${lastNumber + 1}';
    
    final newToken = QueueToken(tokenNumber: newTokenNumber, serviceName: serviceName);
    tokens.add(newToken);
    currentCitizenToken = newToken;
    
    // Reset notification state for the new token
    notifications.clear();
    _triggeredDistances.clear();
    
    notifyListeners();
    _checkCitizenQueueStatus();
    return newToken;
  }

  int getPeopleAhead(QueueToken token) {
    int index = tokens.indexOf(token);
    if (index == -1) return 0;
    
    int ahead = 0;
    for (int i = 0; i < index; i++) {
      if (tokens[i].status == TokenStatus.waiting || tokens[i].status == TokenStatus.serving) {
        ahead++;
      }
    }
    return ahead;
  }

  QueueToken? get currentlyServing {
    try {
      return tokens.firstWhere((t) => t.status == TokenStatus.serving);
    } catch (e) {
      return null;
    }
  }

  void _checkCitizenQueueStatus() {
    if (currentCitizenToken == null) return;
    
    final token = currentCitizenToken!;
    
    if (token.status == TokenStatus.serving) {
      if (!_triggeredDistances.contains(0)) {
        _triggeredDistances.add(0);
        _addNotification(
          'Your turn!',
          'Token ${token.tokenNumber} is now being served.\nPlease proceed to Counter 3.',
        );
      }
      return;
    }

    if (token.status == TokenStatus.waiting) {
      int peopleAhead = getPeopleAhead(token);
      
      if (peopleAhead == 3 && !_triggeredDistances.contains(3)) {
        _triggeredDistances.add(3);
        _addNotification('Your turn is approaching', 'Only 3 people are ahead of you.');
      } else if (peopleAhead == 2 && !_triggeredDistances.contains(2)) {
        _triggeredDistances.add(2);
        _addNotification('Please stay ready', 'Only 2 people are ahead of you.');
      } else if (peopleAhead == 1 && !_triggeredDistances.contains(1)) {
        _triggeredDistances.add(1);
        _addNotification('You\'re next', 'Please be ready to proceed to the counter.');
      }
    }
  }

  void _addNotification(String title, String message) {
    notifications.insert(
      0, // Add to top
      QueueNotification(
        title: title,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  int get unreadNotificationsCount => notifications.where((n) => !n.isRead).length;

  void markAllNotificationsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  // --- Staff Methods ---

  List<QueueToken> get waitingTokens => tokens.where((t) => t.status == TokenStatus.waiting).toList();
  int get waitingCount => waitingTokens.length;
  int get servingCount => currentlyServing != null ? 1 : 0;

  void callNextToken({String? serviceFilter}) {
    if (currentlyServing != null) return;
    
    List<QueueToken> available = waitingTokens;
    if (serviceFilter != null && serviceFilter != 'All Services') {
      available = available.where((t) => t.serviceName == serviceFilter).toList();
    }
    
    if (available.isNotEmpty) {
      available.first.status = TokenStatus.serving;
      notifyListeners();
      _checkCitizenQueueStatus();
    }
  }

  void markAsServed() {
    final current = currentlyServing;
    if (current != null) {
      current.status = TokenStatus.served;
      servedCount++;
      notifyListeners();
      _checkCitizenQueueStatus();
    }
  }

  void skipToken() {
    final current = currentlyServing;
    if (current != null) {
      current.status = TokenStatus.skipped;
      skippedCount++;
      notifyListeners();
      _checkCitizenQueueStatus();
    }
  }
}
