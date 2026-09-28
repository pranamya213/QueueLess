class QueueNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  QueueNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}
