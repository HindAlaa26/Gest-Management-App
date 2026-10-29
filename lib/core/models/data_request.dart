enum DataRequestType { export, delete }

enum DataRequestStatus { pending, inProgress, done, failed }

class DataRequest {
  const DataRequest({
    required this.id,
    required this.type,
    required this.status,
    required this.requestedAt,
    this.completedAt,
    this.downloadUrl,
    this.downloadExpiresAt,
  });

  final String id;
  final DataRequestType type;
  final DataRequestStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;

  final String? downloadUrl;
  final DateTime? downloadExpiresAt;

  bool get isActive =>
      status == DataRequestStatus.pending ||
      status == DataRequestStatus.inProgress;

  DateTime get deadline => requestedAt.add(const Duration(hours: 24));

  bool get linkExpired {
    final expires = downloadExpiresAt;
    return expires != null && DateTime.now().isAfter(expires);
  }

  bool get canDownload =>
      type == DataRequestType.export &&
      status == DataRequestStatus.done &&
      downloadUrl != null &&
      !linkExpired;
}

class DataRequestInProgressException implements Exception {}
