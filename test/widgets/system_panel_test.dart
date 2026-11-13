import 'package:flauncher/widgets/system_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  var reads = 0;
  final calls = <String>[];

  setUp(() {
    reads = 0;
    calls.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(systemChannel,
        (call) async {
      calls.add(call.method);
      if (call.method == 'getSystemStats') {
        reads++;
        return {'cpuPercent': 42, 'memoryUsedMb': 700, 'memoryTotalMb': 1793};
      }
      if (call.method == 'getInputs') {
        return [
          {'id': 'service/input', 'name': 'Live TV', 'physical': false}
        ];
      }
      return true;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(systemChannel, null);
  });

  testWidgets('shows device readings and stops sampling outside foreground',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SystemStats())));
    await tester.pump();
    expect(find.text('CPU 42%'), findsOneWidget);
    expect(find.text('Memory 700 / 1793 MB'), findsOneWidget);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    final pausedReads = reads;
    await tester.pump(const Duration(seconds: 9));
    expect(reads, pausedReads);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(reads, greaterThan(pausedReads));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Network opens settings and Inputs explains app-only sources',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SystemButtons())));
    await tester.tap(find.text('Network'));
    await tester.pump();
    expect(calls, contains('openNetwork'));
    await tester.tap(find.text('Inputs'));
    await tester.pumpAndSettle();
    expect(find.text('Live TV'), findsOneWidget);
    expect(find.textContaining('TV remote'), findsOneWidget);
    await tester.tap(find.text('Live TV'));
    await tester.pumpAndSettle();
    expect(calls, contains('openInput'));
  });
}
