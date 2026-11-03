import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gest_managment_app/core/network/api_client.dart';

class DataExportFile {
  static Future<bool> open(String exportId) async {
    try {
      return await _fetchAndOpen(exportId, 'pdf');
    } on ApiException catch (error) {
      if (error.statusCode != 404) rethrow;
      return _fetchAndOpen(exportId, 'json');
    }
  }

  static Future<bool> _fetchAndOpen(String exportId, String format) async {
    final tokenJson = await ApiClient.post(
      '/api/guest-app/exports/$exportId/download-token',
      format,
    );
    final secret = (tokenJson['data'] as Map<String, dynamic>)['secret'] as String;

    final bytes = await ApiClient.getBytes(
      '/api/guest-app/exports/$exportId/download',
      query: {'format': format},
      headers: {'X-Guest-Export-Secret': secret},
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/my-data.$format');
    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFilex.open(file.path);
    return result.type == ResultType.done;
  }
}
