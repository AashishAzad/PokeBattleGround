import 'package:flutter/material.dart';

import 'app_background.dart';

/// Standard page shell: the animated [AppBackground] behind a transparent
/// [Scaffold] and app bar, with content kept inside the safe area.
/// Every screen uses this so the look stays consistent app-wide.
class GlassScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const GlassScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final hasAppBar = title != null || bottom != null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: hasAppBar
            ? AppBar(
                title: title != null ? Text(title!) : null,
                actions: actions,
                bottom: bottom,
              )
            : null,
        body: SafeArea(top: !hasAppBar, child: body),
      ),
    );
  }
}
