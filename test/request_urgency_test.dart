import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

void main() {
  test('urgencies are equal by name, ignoring case', () {
    expect(const RequestUrgency('normal'), RequestUrgency.normal);
    expect(const RequestUrgency('Critical'), const RequestUrgency('CRITICAL'));
    expect(RequestUrgency.urgent == RequestUrgency.emergency, isFalse);
  });

  test('the picker shows the three built-in urgencies until the list loads', () {
    expect(
      RequestLookups.urgencies.map((u) => u.label),
      ['Normal', 'Urgent', 'Emergency'],
    );
  });

  test('a new backend urgency gets a readable label', () {
    expect(const RequestUrgency('VeryUrgent').label, 'Very urgent');
    expect(const RequestUrgency('Critical').name, 'Critical');
  });
}
