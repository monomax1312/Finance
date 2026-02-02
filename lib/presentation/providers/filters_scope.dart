import 'package:flutter/material.dart';

import 'filters_notifier.dart';

class FiltersScope extends StatefulWidget {
  const FiltersScope({super.key, required this.child});

  final Widget child;

  static FiltersNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FiltersInherited>();
    assert(scope != null, 'FiltersScope not found in widget tree');
    return scope!.notifier!;
  }

  @override
  State<FiltersScope> createState() => _FiltersScopeState();
}

class _FiltersScopeState extends State<FiltersScope> {
  late final FiltersNotifier _notifier = FiltersNotifier();

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FiltersInherited(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _FiltersInherited extends InheritedNotifier<FiltersNotifier> {
  const _FiltersInherited({
    required super.notifier,
    required super.child,
  });
}
