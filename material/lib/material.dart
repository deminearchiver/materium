library;

export 'src/material/color/color_theme.dart';
export 'src/material/color/palette_theme.dart';

export 'src/material/icon/icon.dart';
export 'src/material/icon/icon_theme.dart';

export 'src/material/motion/duration_theme.dart';
export 'src/material/motion/easing_theme.dart';
export 'src/material/motion/spring_theme.dart';

export 'src/material/shape/corners_border.dart';
export 'src/material/shape/corners.dart';
export 'src/material/shape/shape_theme.dart';

export 'src/material/state/state.dart';
export 'src/material/state/state_theme.dart';

export 'src/material/typography/type_style.dart';
export 'src/material/typography/typeface_theme.dart';
export 'src/material/typography/typescale_theme.dart';

export 'src/material/elevation/elevation_theme.dart';

export 'src/material/focus_ring/focus_ring_theme.dart';
export 'src/material/focus_ring/focus_ring.dart';

export 'src/material/progress_indicator.dart';

export 'src/material/checkbox.dart';

export 'src/material/radio_button.dart';

export 'src/material/switch.dart';

export 'src/material/window_size_class.dart';

export 'src/material/animation_extensions.dart';

export 'src/material/center_optically.dart';

export 'src/material/list/list_theme.dart';

// TODO: review after LoadingIndicator gets a custom implementation
export 'src/material/loading_indicator/loading_indicator.dart';
export 'src/material/loading_indicator/loading_indicator_theme.dart';

import 'src/material/flutter.dart';

extension PaintingContextExtension on PaintingContext {
  void withCanvasTransform(void Function(PaintingContext context) paint) {
    late int debugPreviousCanvasSaveCount;
    canvas.save();
    assert(() {
      debugPreviousCanvasSaveCount = canvas.getSaveCount();
      return true;
    }());

    paint(this);

    assert(() {
      // This isn't perfect. For example, we can't catch the case of
      // someone first restoring, then setting a transform or whatnot,
      // then saving.
      // If this becomes a real problem, we could add logic to the
      // Canvas class to lock the canvas at a particular save count
      // such that restore() fails if it would take the lock count
      // below that number.
      final int debugNewCanvasSaveCount = canvas.getSaveCount();
      if (debugNewCanvasSaveCount > debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            "The caller invoked canvas.save() or canvas.saveLayer() at least "
            "${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount} more "
            "time${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount == 1 ? "" : "s"} "
            "than it called canvas.restore().",
          ),
          ErrorDescription(
            "This leaves the canvas in an inconsistent state and will probably result in a broken display.",
          ),
          ErrorHint(
            "You must pair each call to save()/saveLayer() with a later matching call to restore().",
          ),
        ]);
      }
      if (debugNewCanvasSaveCount < debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            "The caller invoked canvas.restore() "
            "${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount} more "
            "time${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount == 1 ? "" : "s"} "
            "than it called canvas.save() or canvas.saveLayer().",
          ),
          ErrorDescription(
            "This leaves the canvas in an inconsistent state and will result in a broken display.",
          ),
          ErrorHint(
            "You should only call restore() if you first called save() or saveLayer().",
          ),
        ]);
      }
      return debugNewCanvasSaveCount == debugPreviousCanvasSaveCount;
    }());

    canvas.restore();
  }
}

extension CanvasExtension on Canvas {
  void withTransform(void Function(Canvas canvas) paint) {
    late int debugPreviousCanvasSaveCount;
    save();
    assert(() {
      debugPreviousCanvasSaveCount = getSaveCount();
      return true;
    }());

    paint(this);

    assert(() {
      // This isn't perfect. For example, we can't catch the case of
      // someone first restoring, then setting a transform or whatnot,
      // then saving.
      // If this becomes a real problem, we could add logic to the
      // Canvas class to lock the canvas at a particular save count
      // such that restore() fails if it would take the lock count
      // below that number.
      final int debugNewCanvasSaveCount = getSaveCount();
      if (debugNewCanvasSaveCount > debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            "The caller invoked canvas.save() or canvas.saveLayer() at least "
            "${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount} more "
            "time${debugNewCanvasSaveCount - debugPreviousCanvasSaveCount == 1 ? "" : "s"} "
            "than it called canvas.restore().",
          ),
          ErrorDescription(
            "This leaves the canvas in an inconsistent state and will probably result in a broken display.",
          ),
          ErrorHint(
            "You must pair each call to save()/saveLayer() with a later matching call to restore().",
          ),
        ]);
      }
      if (debugNewCanvasSaveCount < debugPreviousCanvasSaveCount) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            "The caller invoked canvas.restore() "
            "${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount} more "
            "time${debugPreviousCanvasSaveCount - debugNewCanvasSaveCount == 1 ? "" : "s"} "
            "than it called canvas.save() or canvas.saveLayer().",
          ),
          ErrorDescription(
            "This leaves the canvas in an inconsistent state and will result in a broken display.",
          ),
          ErrorHint(
            "You should only call restore() if you first called save() or saveLayer().",
          ),
        ]);
      }
      return debugNewCanvasSaveCount == debugPreviousCanvasSaveCount;
    }());

    restore();
  }
}

extension OverlayChildLayoutInfoExtension on OverlayChildLayoutInfo {
  double get translationX => childPaintTransform.storage[12];
  double get translationY => childPaintTransform.storage[13];
  double get translationZ => childPaintTransform.storage[14];

  double get scaleX => childPaintTransform[0];
  double get scaleY => childPaintTransform[5];
  double get scaleZ => childPaintTransform[10];
}
