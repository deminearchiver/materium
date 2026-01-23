import 'package:flutter/material.dart';
import 'package:materium/components/sliver_dynamic_header_basic.dart';

// TODO(deminearchiver): make everything actually work.

// enum AppBarExpansionState { expanded, collapsed }

// abstract interface class AppBarStates {}

// class AppBarThemeDataPartial {}

abstract class AppBarDelegate {}

class FlexibleAppBarDelegate extends AppBarDelegate {
  // Title and subtitle, height change allowed
}

// TODO(deminearchiver): extract ExpressiveAppBar and rename to AppBar.
class ExpressiveAppBar extends StatefulWidget {
  const ExpressiveAppBar({super.key, this.title, this.subtitle});

  final Widget? title;
  final Widget? subtitle;

  @override
  State<ExpressiveAppBar> createState() => _ExpressiveAppBarState();
}

class _ExpressiveAppBarState extends State<ExpressiveAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverDynamicHeader(
      minExtentPrototype: const SizedBox(height: 64.0),
      maxExtentPrototype: const SizedBox(height: 64.0),
      builder: (context, layoutInfo) => const SizedBox(height: 64.0),
    );
  }
}
