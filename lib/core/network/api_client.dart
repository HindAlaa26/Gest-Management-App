import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:gest_managment_app/core/network/api_config.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(401, message);
}

class NetworkException implements Exception {}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 20);

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) {
    return _send('GET', path, query: query, auth: auth);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Object? body, {
    bool auth = true,
  }) {
    return _send('POST', path, body: body, auth: auth);
  }

  static Future<Map<String, dynamic>> delete(
    String path,
    Object? body, {
    bool auth = true,
  }) {
    return _send('DELETE', path, body: body, auth: auth);
  }

  static Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);

    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final token = Session.token;
    if (auth && token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final http.Response response;
    try {
      final streamed = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw NetworkException();
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    }

    var json = <String, dynamic>{};
    if (response.bodyBytes.isNotEmpty) {
      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {}
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return json;


    final error = json['error'];
    final message = json['message'];
    final title = json['title'];
    final text = (error is String && error.isNotEmpty)
        ? error
        : (message is String && message.isNotEmpty)
            ? message
            : (title is String ? title : 'Request failed');

    if (response.statusCode == 401) throw UnauthorizedException(text);
    throw ApiException(response.statusCode, text);
  }
}
