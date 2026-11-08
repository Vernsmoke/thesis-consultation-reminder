import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thesis_consultations/main.dart';

void main() {
  testWidgets('Sign in validates fields before any request', (tester) async {
    await tester.pumpWidget(const ConsultationApp());
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [390.0, 768.0, 1440.0]) {
    testWidgets('Sign in fits viewport $width with keyboard labels', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const ConsultationApp());
      await tester.pump();
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
