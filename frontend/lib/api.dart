import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiFailure implements Exception {
  final String message;
  final int status;
  final String? correlation;
  ApiFailure(this.message, this.status, [this.correlation]);
  @override
  String toString() =>
      '$message${correlation == null ? '' : ' Reference: $correlation'}';
}

class Api {
  static const base = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://localhost:8443/api',
  );
  final http.Client client;
  String? token;
  Api({http.Client? client}) : client = client ?? http.Client();
  Future<Map<String, dynamic>> call(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? key,
  }) async {
    try {
      final request = http.Request(method, Uri.parse('$base$path'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Idempotency-Key': ?key,
      });
      if (body != null) request.body = jsonEncode(body);
      final response = await http.Response.fromStream(
        await client.send(request).timeout(const Duration(seconds: 8)),
      ).timeout(const Duration(seconds: 8));
      late final Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw ApiFailure(
          'The service returned an unexpected response. Try again or contact the coordinator.',
          502,
          response.headers['x-correlation-id'],
        );
      } on TypeError {
        throw ApiFailure(
          'The service returned an unexpected response. Try again or contact the coordinator.',
          502,
          response.headers['x-correlation-id'],
        );
      }
      if (response.statusCode >= 400) {
        final errors = (data['errors'] as Map?)?.values
            .expand((e) => e as List)
            .join(' ');
        throw ApiFailure(
          errors ?? data['message'] ?? 'Request failed.',
          response.statusCode,
          response.headers['x-correlation-id'],
        );
      }
      return data;
    } on ApiFailure {
      rethrow;
    } on TimeoutException {
      throw ApiFailure(
        key == null
            ? 'The service timed out. Check the current status before retrying to avoid a duplicate action.'
            : 'The service timed out. Your request may have saved; retry with the same form and idempotency key.',
        0,
      );
    } catch (_) {
      throw ApiFailure(
        'Cannot reach the service. Check the API and try again.',
        0,
      );
    }
  }
}
