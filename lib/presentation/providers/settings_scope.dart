import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';

class SettingsScope extends StatefulWidget {
  const SettingsScope({
    super.key,
    required this.controller,
    required this.child,
  });

  final SettingsController controller;
  final Widget child;

  static SettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_SettingsInherited>();
    assert(scope != null, 'SettingsScope not found in widget tree');
    return scope!.notifier!;
  }

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

class _SettingsScopeState extends State<SettingsScope> {
  @override
  Widget build(BuildContext context) {
    return _SettingsInherited(
      notifier: widget.controller,
      child: widget.child,
    );
  }
}

class _SettingsInherited extends InheritedNotifier<SettingsController> {
  const _SettingsInherited({
    required super.notifier,
    required super.child,
  });
}
