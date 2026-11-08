import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thesis_consultations/api.dart';
import 'package:thesis_consultations/main.dart';

void main() {
  Future<void> login(WidgetTester tester, Api api, String role) async {
    await tester.pumpWidget(MaterialApp(home: Workspace(api: api)));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      '$role@example.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'test-only');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  Map<String, dynamic> consultation() => {
    'id': 4,
    'status': 'confirmed',
    'scheduled_at': '2030-01-01 10:00:00',
    'agenda': 'Controlled secure exchange review',
    'action_items': <dynamic>[],
  };

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.dragUntilVisible(
      finder,
      find.byType(ListView),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Coordinator prepares ciphertext without a client key', (
    tester,
  ) async {
    final api = Api(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return http.Response(
            jsonEncode({
              'token': 'test-token',
              'user': {
                'id': 4,
                'name': 'Taylor Coordinator',
                'role': 'coordinator',
              },
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/automation')) {
          return http.Response(
            jsonEncode({
              'data': [],
              'metrics': {
                'pending': 0,
                'delivered': 0,
                'manual_review': 0,
                'attempts': 0,
              },
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/secure-exchange/envelopes')) {
          return http.Response(
            jsonEncode({
              'envelope': {
                'version': 1,
                'key_id': 'test-v1',
                'message_id': '00000000-0000-4000-8000-000000000001',
                'issued_at': '2030-01-01T00:00:00Z',
                'expires_at': '2030-01-01T00:05:00Z',
                'sender': 'thesis-consultation-api',
                'recipient_user_id': 2,
                'nonce': 'controlled-nonce',
                'ciphertext': 'controlled-ciphertext',
                'tag': 'controlled-tag',
              },
            }),
            201,
          );
        }
        return http.Response(
          jsonEncode({
            'data': [consultation()],
            'directory': [],
            'notifications': [],
          }),
          200,
        );
      }),
    );
    await login(tester, api, 'coordinator');
    await scrollTo(tester, find.text('Prepare secure envelope'));
    await tester.tap(find.text('Prepare secure envelope'));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('Encrypted adviser envelope'));
    expect(find.text('Encrypted adviser envelope'), findsOneWidget);
    expect(find.textContaining('controlled-ciphertext'), findsOneWidget);
    expect(find.textContaining('SECURE_EXCHANGE_KEY'), findsNothing);
  });

  testWidgets(
    'Assigned adviser receives verified record and sees replay-safe UI',
    (tester) async {
      final api = Api(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            return http.Response(
              jsonEncode({
                'token': 'test-token',
                'user': {'id': 2, 'name': 'Casey Adviser', 'role': 'adviser'},
              }),
              200,
            );
          }
          if (request.url.path.endsWith('/secure-exchange/receive')) {
            return http.Response(
              jsonEncode({
                'message': 'Secure consultation record accepted.',
                'record': {
                  'consultation_id': 4,
                  'agenda': 'Controlled secure exchange review',
                  'status': 'confirmed',
                  'scheduled_at': '2030-01-01T10:00:00Z',
                  'open_action_count': 0,
                },
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'data': [consultation()],
              'directory': [],
              'notifications': [],
            }),
            200,
          );
        }),
      );
      await login(tester, api, 'adviser');
      await scrollTo(
        tester,
        find.text('Receive protected consultation record'),
      );
      await tester.enterText(
        find.byType(TextField).last,
        jsonEncode({'version': 1}),
      );
      await tester.tap(find.text('Verify and receive'));
      await tester.pumpAndSettle();
      expect(find.text('Accepted consultation #4'), findsOneWidget);
    },
  );

  testWidgets('Malformed local JSON shows validation feedback before network', (
    tester,
  ) async {
    final api = Api(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return http.Response(
            jsonEncode({
              'token': 'test-token',
              'user': {'id': 2, 'name': 'Casey Adviser', 'role': 'adviser'},
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'data': [consultation()],
            'directory': [],
            'notifications': [],
          }),
          200,
        );
      }),
    );
    await login(tester, api, 'adviser');
    await scrollTo(tester, find.text('Receive protected consultation record'));
    await tester.enterText(find.byType(TextField).last, 'not-json');
    await tester.tap(find.text('Verify and receive'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter a valid JSON envelope.'), findsOneWidget);
  });
}
