/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const longPressableKeys = [
  LogicalKeyboardKey.select,
  LogicalKeyboardKey.enter,
  LogicalKeyboardKey.gameButtonA
];

class FocusKeyboardListener extends StatefulWidget {
  final WidgetBuilder builder;
  final KeyEventResult Function(LogicalKeyboardKey)? onPressed;
  final KeyEventResult Function(LogicalKeyboardKey)? onLongPress;

  FocusKeyboardListener({
    Key? key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  @override
  _FocusKeyboardListenerState createState() => _FocusKeyboardListenerState();
}

class _FocusKeyboardListenerState extends State<FocusKeyboardListener>
    with WidgetsBindingObserver {
  Timer? _holdTimer;
  LogicalKeyboardKey? _heldKey;
  bool _longPressFired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _heldKey = null;
    _longPressFired = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _cancelHold();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
        canRequestFocus: false,
        onFocusChange: (focused) {
          if (!focused) _cancelHold();
        },
        onKey: (_, rawKeyEvent) => _handleKey(context, rawKeyEvent),
        child: Builder(builder: widget.builder),
      );

  KeyEventResult _handleKey(BuildContext context, RawKeyEvent rawKeyEvent) {
    switch (rawKeyEvent.runtimeType) {
      case RawKeyDownEvent:
        return _keyDownEvent(context, rawKeyEvent.logicalKey);
      case RawKeyUpEvent:
        return _keyUpEvent(context, rawKeyEvent.logicalKey);
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _keyDownEvent(BuildContext context, LogicalKeyboardKey key) {
    if (!longPressableKeys.contains(key) || widget.onLongPress == null) {
      return widget.onPressed?.call(key) ?? KeyEventResult.ignored;
    }
    // Own the entire Select gesture, preventing the default button action from
    // launching on key-down. Remotes need not emit Android repeat events.
    if (_heldKey == key) return KeyEventResult.handled;
    _cancelHold();
    _heldKey = key;
    _holdTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _heldKey != key) return;
      _longPressFired = true;
      _holdTimer = null;
      widget.onLongPress?.call(key);
    });
    return KeyEventResult.handled;
  }

  KeyEventResult _keyUpEvent(BuildContext context, LogicalKeyboardKey key) {
    if (_heldKey == key) {
      final wasLongPress = _longPressFired;
      _cancelHold();
      return wasLongPress
          ? KeyEventResult.handled
          : widget.onPressed?.call(key) ?? KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
