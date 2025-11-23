import 'dart:io';

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:jni/jni.dart';

import 'jni_bindings.dart' as jb;

abstract final class DynamicColor {
  JObject? _getContext() {
    if (!Platform.isAndroid) return null;
    return Jni.androidApplicationContext;
  }

  bool isDynamicColorAvailable() =>
      jb.DynamicColorPlugin.isDynamicColorAvailable();
}
