import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client, required this.accessToken}) : _client = client ?? http.Client();
  final http.Client _client;
  final String accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        if (AppConfig.demoMode) 'X-Demo-User': accessToken,
      };

  Future<Map<String, dynamic>> get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path').replace(queryParameters: query);
    return _decode(await _client.get(uri, headers: _headers));
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path').replace(queryParameters: query);
    return _decode(await _client.post(uri, headers: _headers, body: jsonEncode(body)));
  }

  Map<String, dynamic> _decode(http.Response response) {
    final dynamic payload = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = payload is Map<String, dynamic> ? payload['detail'] : null;
      throw ApiException(detail?.toString() ?? 'Request failed (${response.statusCode})');
    }
    return Map<String, dynamic>.from(payload as Map);
  }

  void dispose() => _client.close();
}

