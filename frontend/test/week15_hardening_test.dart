import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thesis_consultations/api.dart';
import 'package:thesis_consultations/main.dart';

void main() {
  test('Non-idempotent timeout warns to check status before retry', () async {
    final api = Api(
      client: MockClient((request) async {
        throw TimeoutException('Controlled timeout');
      }),
    );

    await expectLater(
      api.call('POST', '/secure-exchange/receive', body: {'version': 1}),
      throwsA(
        isA<ApiFailure>()
            .having((failure) => failure.status, 'status', 0)
            .having(
              (failure) => failure.message,
              'message',
              contains('Check the current status before retrying'),
            ),
      ),
    );
  });

  test('Idempotent timeout retains safe same-key retry guidance', () async {
    final api = Api(
      client: MockClient((request) async {
        throw TimeoutException('Controlled timeout');
      }),
    );

    await expectLater(
      api.call(
        'POST',
        '/consultations',
        key: 'week15_fixture_key',
        body: {'agenda': 'Controlled timeout'},
      ),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.message,
          'message',
          contains('same form'),
        ),
      ),
    );
  });

  test('Malformed success response is reported as a protocol failure', () async {
    final api = Api(
      client: MockClient((request) async => http.Response('<html>bad gateway</html>', 200)),
    );

    await expectLater(
      api.call('GET', '/consultations'),
      throwsA(
        isA<ApiFailure>()
            .having((failure) => failure.status, 'status', 502)
            .having(
              (failure) => failure.message,
              'message',
              contains('unexpected response'),
            ),
      ),
    );
  });

  testWidgets('Login password boundary agrees with the API maximum', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var requests = 0;
    final api = Api(
      client: MockClient((request) async {
        requests++;
        return http.Response('{"message":"should not be called"}', 500);
      }),
    );
    await tester.pumpWidget(MaterialApp(home: Workspace(api: api)));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'week15-student@example.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'x' * 129);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Use no more than 128 characters.'), findsOneWidget);
    expect(requests, 0);
  });
}
