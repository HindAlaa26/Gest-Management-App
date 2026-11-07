import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

void main() {
  test('backend names become readable labels', () {
    expect(RequestLookups.humanize('InProgress'), 'In progress');
    expect(RequestLookups.humanize('Emergency'), 'Emergency');
    expect(RequestLookups.humanize('New'), 'New');
  });

  test('labels fall back to the built-in text when nothing is loaded', () {
    expect(RequestStatus.inProgress.label, 'In progress');
    expect(RequestStatus.failed.label, 'Not completed');
    expect(RequestUrgency.urgent.label, 'Urgent');
  });
}
