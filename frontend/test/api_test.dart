import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thesis_consultations/api.dart';

void main() {
  test(
    'Safe API error retains correlation and authorization outcome',
    () async {
      final api = Api(
        client: MockClient(
          (r) async => http.Response(
            '{"message":"Coordinator required."}',
            403,
            headers: {'x-correlation-id': 'test-reference'},
          ),
        ),
      );
      await expectLater(
        api.call('GET', '/automation'),
        throwsA(
          isA<ApiFailure>()
              .having((e) => e.status, 'status', 403)
              .having((e) => e.correlation, 'reference', 'test-reference'),
        ),
      );
    },
  );
  test('Network failure becomes actionable feedback', () async {
    final api = Api(
      client: MockClient(
        (r) async =>
            throw http.ClientException('Controlled unavailable service'),
      ),
    );
    await expectLater(
      api.call('GET', '/consultations'),
      throwsA(isA<ApiFailure>().having((e) => e.status, 'status', 0)),
    );
  });
  test('Timeout becomes safe retry feedback', () async {
    final api = Api(
      client: MockClient(
        (r) async => throw TimeoutException('Controlled timeout'),
      ),
    );
    await expectLater(
      api.call('POST', '/consultations', key: 'controlled_retry_key'),
      throwsA(
        isA<ApiFailure>().having(
          (e) => e.message,
          'message',
          contains('same form'),
        ),
      ),
    );
  });
}
