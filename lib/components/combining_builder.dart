import 'package:materium/flutter.dart';

class CombiningBuilder extends StatelessWidget {
  const CombiningBuilder({
    super.key,
    this.useOuterContext = false,
    required this.builders,
    required this.child,
  });

  final bool useOuterContext;

  final List<Widget Function(BuildContext context, Widget child)> builders;

  /// The child widget to pass to the last of [builders].
  final Widget child;

  @override
  Widget build(BuildContext outerContext) => builders.reversed.fold(
    child,
    (child, buildOuter) => useOuterContext
        ? buildOuter(outerContext, child)
        : Builder(builder: (innerContext) => buildOuter(innerContext, child)),
  );
}
