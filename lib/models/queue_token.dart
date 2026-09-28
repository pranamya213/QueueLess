enum TokenStatus { waiting, serving, served, skipped }

class QueueToken {
  final String tokenNumber;
  final String serviceName;
  TokenStatus status;

  QueueToken({
    required this.tokenNumber,
    required this.serviceName,
    this.status = TokenStatus.waiting,
  });
}
