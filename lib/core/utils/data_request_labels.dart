import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';

extension DataRequestTypeLabels on DataRequestType {
  String get title {
    switch (this) {
      case DataRequestType.export:
        return 'Copy of my data';
      case DataRequestType.delete:
        return 'Delete my data';
    }
  }

  IconData get icon {
    switch (this) {
      case DataRequestType.export:
        return Icons.download_outlined;
      case DataRequestType.delete:
        return Icons.delete_outline;
    }
  }
}

extension DataRequestStatusLabels on DataRequestStatus {
  String get label {
    switch (this) {
      case DataRequestStatus.pending:
        return 'Received';
      case DataRequestStatus.inProgress:
        return 'In progress';
      case DataRequestStatus.done:
        return 'Done';
      case DataRequestStatus.failed:
        return 'Failed';
    }
  }
}

/// The sentence under a request: what is happening and what to expect.
String dataRequestNote(DataRequest request) {
  if (request.status == DataRequestStatus.failed) {
    return request.type == DataRequestType.export
        ? 'We could not prepare your copy. Please contact the hotel team.'
        : 'We could not finish deleting your data. Please contact the hotel team.';
  }

  if (request.type == DataRequestType.export) {
    if (request.isActive) {
      return "We're preparing your file. It will be ready here soon.";
    }
    if (request.linkExpired) {
      return 'This download link has expired. Ask for a new copy.';
    }
    final expires = request.downloadExpiresAt;
    return expires == null
        ? 'Your copy is ready.'
        : 'Your copy is ready. The link works until ${formatDay(expires)}.';
  }

  if (request.isActive) {
    return 'We will finish by ${formatDateTime(request.deadline)}.';
  }
  final at = request.completedAt;
  return at == null
      ? 'Your personal data was removed.'
      : 'Your personal data was removed on ${formatDay(at)}.';
}
