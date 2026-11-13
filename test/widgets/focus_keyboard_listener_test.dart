import 'package:flauncher/widgets/focus_keyboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('holding Select without repeats opens menu and never launches',
      (tester) async {
    var presses = 0;
    var holds = 0;
    var defaultActivations = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FocusKeyboardListener(
      onPressed: (_) {
        presses++;
        return KeyEventResult.handled;
      },
      onLongPress: (_) {
        holds++;
        return KeyEventResult.handled;
      },
      builder: (_) => TextButton(
          autofocus: true,
          onPressed: () => defaultActivations++,
          child: const Text('App')),
    ))));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 600));
    expect(holds, 1);
    expect(presses, 0);
    expect(defaultActivations, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(presses, 0);
    expect(defaultActivations, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('short Select still launches once on release', (tester) async {
    var presses = 0;
    var holds = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: FocusKeyboardListener(
      onPressed: (_) {
        presses++;
        return KeyEventResult.handled;
      },
      onLongPress: (_) {
        holds++;
        return KeyEventResult.handled;
      },
      builder: (_) => TextButton(
          autofocus: true,
          onPressed: () => fail('Select leaked to default activation'),
          child: const Text('App')),
    ))));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 100));
    expect(presses, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pump();
    expect(presses, 1);
    expect(holds, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('focus leaving the app cancels its pending long press',
      (tester) async {
    var holds = 0;
    final otherFocus = FocusNode();
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Column(children: [
      FocusKeyboardListener(
        onPressed: (_) => KeyEventResult.handled,
        onLongPress: (_) {
          holds++;
          return KeyEventResult.handled;
        },
        builder: (_) => TextButton(
            autofocus: true, onPressed: () {}, child: const Text('App')),
      ),
      TextButton(
          focusNode: otherFocus, onPressed: () {}, child: const Text('Other')),
    ]))));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    otherFocus.requestFocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(holds, 0);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pumpWidget(const SizedBox());
    otherFocus.dispose();
  });
}
