import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rideload/main.dart';

void main() {
  testWidgets('search and request remain explicitly simulated', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RideloadApp());
    expect(find.text('Load and Ride'), findsOneWidget);
    expect(find.textContaining('No live vehicles'), findsOneWidget);
    await tester.tap(find.text('Find matching trips'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Request demo booking'));
    await tester.tap(find.text('Request demo booking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Demo status: Requested'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate Accepted'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Demo status: Accepted'), findsOneWidget);
  });
  testWidgets('empty location validation and owner gate', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const RideloadApp());
    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Find matching trips'));
    await tester.pumpAndSettle();
    expect(find.text('Enter different pickup and drop locations.'), findsOneWidget);
    await tester.tap(find.text('Post trip'));
    await tester.pumpAndSettle();
    expect(find.text('Vehicle Owner registration'), findsOneWidget);
  });
}
