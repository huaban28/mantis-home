// SPDX-License-Identifier: GPL-3.0-or-later
// Local Mantis Home additions to FLauncher.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const systemChannel = MethodChannel('me.efesser.flauncher/method');

class SystemStats extends StatefulWidget {
  @override
  State<SystemStats> createState() => _SystemStatsState();
}

class _SystemStatsState extends State<SystemStats> with WidgetsBindingObserver {
  Timer? _timer;
  Map<dynamic, dynamic>? _stats;
  bool _busy = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  void _start() {
    _timer?.cancel();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  Future<void> _refresh() async {
    if (_busy || !_active) return;
    _busy = true;
    try {
      final stats = await systemChannel.invokeMapMethod('getSystemStats');
      if (mounted && _active) setState(() => _stats = stats);
    } on PlatformException {
      if (mounted) setState(() => _stats = null);
    } on MissingPluginException {
      // Also keeps existing upstream widget tests usable without a native host.
    } finally {
      _busy = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) {
      _start();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cpu = _stats?['cpuPercent'];
    final used = _stats?['memoryUsedMb'];
    final total = _stats?['memoryTotalMb'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('CPU ${cpu == null ? "—" : "$cpu%"}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        Text(
            used == null || total == null
                ? 'Memory —'
                : 'Memory $used / $total MB',
            style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }
}

class SystemButtons extends StatelessWidget {
  Future<void> _network(BuildContext context) async {
    try {
      if (await systemChannel.invokeMethod<bool>('openNetwork') != true) {
        _message(context, 'Network settings are unavailable on this device.');
      }
    } on PlatformException {
      _message(context, 'Network settings could not be opened.');
    }
  }

  Future<void> _inputs(BuildContext context) async {
    try {
      final inputs =
          await systemChannel.invokeListMethod<dynamic>('getInputs') ?? [];
      final physical = inputs.any((input) => input['physical'] == true);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Inputs'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (!physical)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                        'Switch physical HDMI sources with your TV remote. Available app inputs:'),
                  ),
                if (inputs.isEmpty) const Text('No inputs are available.'),
                for (final input in inputs)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          final opened = await systemChannel.invokeMethod<bool>(
                              'openInput', input['id']);
                          if (opened != true)
                            _message(
                                context, 'This input could not be opened.');
                        },
                        child: Text(input['name'] as String),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'))
          ],
        ),
      );
    } on PlatformException {
      _message(context, 'Inputs are unavailable on this device.');
    }
  }

  void _message(BuildContext context, String message) {
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        OutlinedButton.icon(
            onPressed: () => _inputs(context),
            icon: const Icon(Icons.input),
            label: const Text('Inputs')),
        const SizedBox(width: 12),
        OutlinedButton.icon(
            onPressed: () => _network(context),
            icon: const Icon(Icons.wifi),
            label: const Text('Network')),
        const SizedBox(width: 16),
      ]);
}
