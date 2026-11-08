import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:thesis_consultations/api.dart';
import 'package:thesis_consultations/main.dart';

void main() {
  Future<void> login(WidgetTester tester, Api api) async {
    await tester.pumpWidget(MaterialApp(home: Workspace(api: api)));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@example.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'test-only');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  for (final width in [390.0, 768.0, 1440.0]) {
    testWidgets('Authenticated consultation and updates fit $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = Api(
        client: MockClient(
          (r) async => http.Response(
            jsonEncode(
              r.url.path.endsWith('/login')
                  ? {
                      'token': 'controlled-test-token',
                      'user': {
                        'id': 1,
                        'name': 'Alex Researcher',
                        'role': 'student',
                      },
                    }
                  : {
                      'directory': [],
                      'data': [
                        {
                          'id': 1,
                          'status': 'completed',
                          'scheduled_at': '2030-01-01 10:00:00',
                          'agenda': 'Controlled review of research progress',
                          'action_items': [
                            {
                              'id': 1,
                              'description': 'Revise questions',
                              'due_at': '2030-01-02 10:00:00',
                              'status': 'done',
                            },
                          ],
                        },
                      ],
                      'notifications': [
                        {
                          'kind': 'progress_summary',
                          'delivered_at': '2030-01-01 10:00:00',
                          'payload': {
                            'meetings_completed': 1,
                            'meetings_missed': 0,
                            'open_actions': 0,
                          },
                        },
                      ],
                    },
            ),
            200,
          ),
        ),
      );
      await login(tester, api);
      expect(find.text('Consultation #1'), findsOneWidget);
      expect(find.text('Simulated updates'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final status in [401, 403, 500]) {
    testWidgets('HTTP $status gives visible safe feedback', (tester) async {
      final api = Api(
        client: MockClient(
          (r) async => http.Response(
            '{"message":"Controlled safe failure"}',
            status,
            headers: {'x-correlation-id': 'controlled-reference'},
          ),
        ),
      );
      await login(tester, api);
      expect(find.textContaining('Controlled safe failure'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Empty response gives an understandable state', (tester) async {
    final api = Api(
      client: MockClient(
        (r) async => http.Response(
          jsonEncode(
            r.url.path.endsWith('/login')
                ? {
                    'token': 'test-token',
                    'user': {'id': 1, 'name': 'Alex', 'role': 'student'},
                  }
                : {'data': [], 'directory': [], 'notifications': []},
          ),
          200,
        ),
      ),
    );
    await login(tester, api);
    expect(find.textContaining('No consultations yet.'), findsOneWidget);
  });
  testWidgets('Pending API request displays loading progress', (tester) async {
    final pending = Completer<http.Response>();
    final api = Api(client: MockClient((r) => pending.future));
    await tester.pumpWidget(MaterialApp(home: Workspace(api: api)));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'student@example.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'test-only');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    pending.complete(
      http.Response('{"message":"Controlled safe failure"}', 401),
    );
    await tester.pumpAndSettle();
  });
}
