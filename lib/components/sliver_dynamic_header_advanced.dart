import 'package:materium/flutter.dart';

enum _SliverDynamicHeaderSlot { minExtentPrototype, maxExtentPrototype, child }

abstract class RenderSliverDynamicHeader extends RenderSliver
    with
        SlottedContainerRenderObjectMixin<_SliverDynamicHeaderSlot, RenderBox>,
        RenderSliverHelpers {
  RenderBox? get minExtentPrototype => childForSlot(.minExtentPrototype);
  RenderBox? get maxExtentPrototype => childForSlot(.maxExtentPrototype);
  RenderBox? get child => childForSlot(.child);

  @override
  Iterable<RenderBox> get children => <RenderBox>[
    ?minExtentPrototype,
    ?maxExtentPrototype,
    ?child,
  ];
}
