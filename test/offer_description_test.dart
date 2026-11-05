import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

Map<String, dynamic> _json({String? en, String? ar}) => {
      'id': 'd1',
      'offerTitleEn': 'Spa',
      'offerTitleAr': 'سبا',
      'descriptionEn': en,
      'descriptionAr': ar,
      'offerType': 'Discount',
      'status': 'Sent',
      'redemptionCode': 'ABC',
      'expiredAtUtc': '2026-12-01T00:00:00',
    };

void main() {
  test('description prefers English, falls back to Arabic, may be empty', () {
    expect(ApiService.offerFromJson(_json(en: 'Half price', ar: 'نص السعر')).description, 'Half price');
    expect(ApiService.offerFromJson(_json(ar: 'نص السعر')).description, 'نص السعر');
    expect(ApiService.offerFromJson(_json()).description, '');
  });
}
