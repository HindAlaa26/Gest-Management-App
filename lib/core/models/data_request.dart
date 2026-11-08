enum DataRequestType { export, delete }

enum DataRequestStatus { pending, inProgress, done, failed }

class DataRequest {
  const DataRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.downloadExpiresAt,
  });

  final String id;
  final DataRequestType type;
  final DataRequestStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;

  final DateTime? downloadExpiresAt;

  bool get isActive =>
      status == DataRequestStatus.pending ||
      status == DataRequestStatus.inProgress;

  bool get linkExpired {
    final expires = downloadExpiresAt;
    return expires != null && DateTime.now().isAfter(expires);
  }

  bool get canDownload =>
      type == DataRequestType.export &&
      status == DataRequestStatus.done &&
      !linkExpired;
}

class DataRequestInProgressException implements Exception {}
