import 'dart:ui' show lerpDouble;

import 'package:material/src/material/flutter.dart';

FontWeight _closestFontWeightTo(double weight) {
  assert(weight >= 0, "Font weight cannot be negative.");
  final values = FontWeight.values;
  assert(values.isNotEmpty);
  var closest = values[0];
  for (int i = 1; i < values.length; i++) {
    final element = values[i];
    if ((weight - element.value.toDouble()).abs() <=
        (weight - closest.value.toDouble()).abs()) {
      closest = element;
    }
  }
  return closest;
}

(FontWeight? fontWeight, double? wght) _resolveFontWeights(
  double? weight,
  double? wght,
) {
  if (wght != null) {
    final fontWeight = _closestFontWeightTo(wght);
    return (fontWeight, wght);
  } else if (weight != null && wght == null) {
    final fontWeight = _closestFontWeightTo(weight);
    return (fontWeight, weight);
  } else {
    return (null, null);
  }
}

bool _debugTextStyleHasFont(TextStyle? style) {
  if (style == null) return false;
  if (style.fontFamily != null) return true;
  if (style.fontFamilyFallback case final fontFamilyFallback?) {
    return fontFamilyFallback.isNotEmpty;
  }
  return false;
}

bool _debugTextStyleHasWeight(TextStyle? style) {
  if (style == null) return false;
  if (style.fontWeight != null) return true;
  if (style.fontVariations case final fontVariations?) {
    return fontVariations.any((fontVariation) => fontVariation.axis == "wght");
  }
  return false;
}

bool _debugTextStyleHasSize(TextStyle? style) {
  if (style == null) return false;
  return style.fontSize != null;
}

bool _debugTextStyleHasLineHeight(TextStyle? style) {
  if (style == null) return false;
  return style.fontSize != null && style.height != null;
}

bool _debugTextStyleHasTracking(TextStyle? style) {
  if (style == null) return false;
  return style.letterSpacing != null;
}

extension on FontWeight {
  double _toDouble() => value.toDouble();
}

extension on TextStyle {
  Map<String, double>? get _variableFontAxesOrNull => <String, double>{
    for (final fontVariation in fontVariations ?? const <FontVariation>[])
      fontVariation.axis: fontVariation.value,
  };

  // Map<String, double> get _variableFontAxes => _variableFontAxesOrNull ?? {};

  double? _variableFontAxis(String axis) => _variableFontAxesOrNull?[axis];
}

abstract final class _VariableFontAxes {
  static const String wght = "wght";
  static const String grad = "GRAD";
  static const String wdth = "wdth";
  static const String rond = "ROND";
  static const String opsz = "opsz";
  static const String crsv = "CRSV";
  static const String slnt = "slnt";
  static const String fill = "FILL";
  static const String hexp = "HEXP";
}

@immutable
abstract class TypeStylePartial with Diagnosticable {
  const TypeStylePartial();

  const factory TypeStylePartial.from({
    List<String>? font,
    double? weight,
    double? size,
    double? tracking,
    double? lineHeight,
    double? wght,
    double? grad,
    double? wdth,
    double? rond,
    double? opsz,
    double? crsv,
    double? slnt,
    double? fill,
    double? hexp,
  }) = _TypeStylePartial;

  List<String>? get font;

  double? get weight;

  double? get size;

  double? get tracking;

  double? get lineHeight;

  double? get wght;

  double? get grad;

  double? get wdth;

  double? get rond;

  double? get opsz;

  double? get crsv;

  double? get slnt;

  double? get fill;

  double? get hexp;

  TypeStylePartial copyWith({
    List<String>? font,
    double? weight,
    double? size,
    double? tracking,
    double? lineHeight,
    double? wght,
    double? grad,
    double? wdth,
    double? rond,
    double? opsz,
    double? crsv,
    double? slnt,
    double? fill,
    double? hexp,
  }) =>
      font != null ||
          weight != null ||
          size != null ||
          tracking != null ||
          lineHeight != null ||
          wght != null ||
          grad != null ||
          wdth != null ||
          rond != null ||
          opsz != null ||
          crsv != null ||
          slnt != null ||
          fill != null ||
          hexp != null
      ? TypeStylePartial.from(
          font: font ?? this.font,
          weight: weight ?? this.weight,
          size: size ?? this.size,
          tracking: tracking ?? this.tracking,
          lineHeight: lineHeight ?? this.lineHeight,
          wght: wght ?? this.wght,
          grad: grad ?? this.grad,
          wdth: wdth ?? this.wdth,
          rond: rond ?? this.rond,
          opsz: opsz ?? this.opsz,
          crsv: crsv ?? this.crsv,
          slnt: slnt ?? this.slnt,
          fill: fill ?? this.fill,
          hexp: hexp ?? this.hexp,
        )
      : this;

  TypeStylePartial mergeWith({
    List<String>? font,
    double? weight,
    double? size,
    double? tracking,
    double? lineHeight,
    double? wght,
    double? grad,
    double? wdth,
    double? rond,
    double? opsz,
    double? crsv,
    double? slnt,
    double? fill,
    double? hexp,
  }) =>
      font != null ||
          weight != null ||
          size != null ||
          tracking != null ||
          lineHeight != null ||
          wght != null ||
          grad != null ||
          wdth != null ||
          rond != null ||
          opsz != null ||
          crsv != null ||
          slnt != null ||
          fill != null ||
          hexp != null
      ? TypeStylePartial.from(
          font: font != null ? [...font, ...?this.font] : this.font,
          weight: weight ?? this.weight,
          size: size ?? this.size,
          tracking: tracking ?? this.tracking,
          lineHeight: lineHeight ?? this.lineHeight,
          wght: wght ?? this.wght,
          grad: grad ?? this.grad,
          wdth: wdth ?? this.wdth,
          rond: rond ?? this.rond,
          opsz: opsz ?? this.opsz,
          crsv: crsv ?? this.crsv,
          slnt: slnt ?? this.slnt,
          fill: fill ?? this.fill,
          hexp: hexp ?? this.hexp,
        )
      : this;

  TypeStylePartial merge(TypeStylePartial? other) => other != null
      ? mergeWith(
          font: other.font,
          weight: other.weight,
          size: other.size,
          tracking: other.tracking,
          lineHeight: other.lineHeight,
          wght: other.wght,
          grad: other.grad,
          wdth: other.wdth,
          rond: other.rond,
          opsz: other.opsz,
          crsv: other.crsv,
          slnt: other.slnt,
          fill: other.fill,
          hexp: other.hexp,
        )
      : this;

  Map<String, double> get variableFontAxes => {
    if (wght case final wght?) _VariableFontAxes.wght: wght,
    if (grad case final grad?) _VariableFontAxes.grad: grad,
    if (wdth case final wdth?) _VariableFontAxes.wdth: wdth,
    if (rond case final rond?) _VariableFontAxes.rond: rond,
    if (opsz case final opsz?) _VariableFontAxes.opsz: opsz,
    if (crsv case final crsv?) _VariableFontAxes.crsv: crsv,
    if (slnt case final slnt?) _VariableFontAxes.slnt: slnt,
    if (fill case final fill?) _VariableFontAxes.fill: fill,
    if (hexp case final hexp?) _VariableFontAxes.hexp: hexp,
  };

  List<FontVariation> get fontVariations => [
    if (wght case final wght?) FontVariation(_VariableFontAxes.wght, wght),
    if (grad case final grad?) FontVariation(_VariableFontAxes.grad, grad),
    if (wdth case final wdth?) FontVariation(_VariableFontAxes.wdth, wdth),
    if (rond case final rond?) FontVariation(_VariableFontAxes.rond, rond),
    if (opsz case final opsz?) FontVariation(_VariableFontAxes.opsz, opsz),
    if (crsv case final crsv?) FontVariation(_VariableFontAxes.crsv, crsv),
    if (slnt case final slnt?) FontVariation(_VariableFontAxes.slnt, slnt),
    if (fill case final fill?) FontVariation(_VariableFontAxes.fill, fill),
    if (hexp case final hexp?) FontVariation(_VariableFontAxes.hexp, hexp),
  ];

  TextStyle toTextStyle({Color? color}) {
    return TextStyle(
      inherit: true,
      fontFamily: font?.firstOrNull,
      fontFamilyFallback: font?.skip(1).toList(),
      fontWeight: weight != null ? _closestFontWeightTo(weight!) : null,
      fontSize: size,
      height: size != null && lineHeight != null ? lineHeight! / size! : null,
      letterSpacing: tracking,
      fontVariations: fontVariations,
      color: color,
    );
  }

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(IterableProperty("font", font, defaultValue: null))
      ..add(DoubleProperty("weight", weight, defaultValue: null))
      ..add(DoubleProperty("size", size, defaultValue: null))
      ..add(DoubleProperty("tracking", tracking, defaultValue: null))
      ..add(DoubleProperty("lineHeight", lineHeight, defaultValue: null))
      ..add(DoubleProperty("wght", wght, defaultValue: null))
      ..add(DoubleProperty("grad", grad, defaultValue: null))
      ..add(DoubleProperty("wdth", wdth, defaultValue: null))
      ..add(DoubleProperty("rond", rond, defaultValue: null))
      ..add(DoubleProperty("opsz", opsz, defaultValue: null))
      ..add(DoubleProperty("crsv", crsv, defaultValue: null))
      ..add(DoubleProperty("slnt", slnt, defaultValue: null))
      ..add(DoubleProperty("fill", fill, defaultValue: null))
      ..add(DoubleProperty("hexp", hexp, defaultValue: null));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is TypeStylePartial &&
          listEquals(font, other.font) &&
          weight == other.weight &&
          size == other.size &&
          tracking == other.tracking &&
          lineHeight == other.lineHeight &&
          wght == other.wght &&
          grad == other.grad &&
          wdth == other.wdth &&
          rond == other.rond &&
          opsz == other.opsz &&
          crsv == other.crsv &&
          slnt == other.slnt &&
          fill == other.fill &&
          hexp == other.hexp;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    font != null ? Object.hashAll(font!) : null,
    weight,
    size,
    tracking,
    lineHeight,
    wght,
    grad,
    wdth,
    rond,
    opsz,
    crsv,
    slnt,
    fill,
    hexp,
  );

  static TypeStylePartial? lerp(
    TypeStylePartial? a,
    TypeStylePartial? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return TypeStylePartial.from(
      font: t < 0.5 ? a?.font : b?.font,
      weight: lerpDouble(a?.weight, b?.weight, t),
      size: lerpDouble(a?.size, b?.size, t),
      lineHeight: lerpDouble(a?.lineHeight, b?.lineHeight, t),
      tracking: lerpDouble(a?.tracking, b?.tracking, t),
      wght: lerpDouble(a?.wght, b?.wght, t),
      grad: lerpDouble(a?.grad, b?.grad, t),
      wdth: lerpDouble(a?.wdth, b?.wdth, t),
      rond: lerpDouble(a?.rond, b?.rond, t),
      opsz: lerpDouble(a?.opsz, b?.opsz, t),
      crsv: lerpDouble(a?.crsv, b?.crsv, t),
      slnt: lerpDouble(a?.slnt, b?.slnt, t),
      fill: lerpDouble(a?.fill, b?.fill, t),
      hexp: lerpDouble(a?.hexp, b?.hexp, t),
    );
  }
}

@immutable
class _TypeStylePartial extends TypeStylePartial {
  const _TypeStylePartial({
    this.font,
    this.weight,
    this.size,
    this.tracking,
    this.lineHeight,
    this.wght,
    this.grad,
    this.wdth,
    this.rond,
    this.opsz,
    this.crsv,
    this.slnt,
    this.fill,
    this.hexp,
  });

  @override
  final List<String>? font;

  @override
  final double? weight;

  @override
  final double? size;

  @override
  final double? tracking;

  @override
  final double? lineHeight;

  @override
  final double? wght;

  @override
  final double? grad;

  @override
  final double? wdth;

  @override
  final double? rond;

  @override
  final double? opsz;

  @override
  final double? crsv;

  @override
  final double? slnt;

  @override
  final double? fill;

  @override
  final double? hexp;
}

@immutable
abstract class TypeStyle extends TypeStylePartial {
  const TypeStyle();

  const factory TypeStyle.from({
    required List<String> font,
    required double weight,
    required double size,
    required double tracking,
    required double lineHeight,
    required double wght,
    required double grad,
    required double wdth,
    required double rond,
    required double opsz,
    required double crsv,
    required double slnt,
    required double fill,
    required double hexp,
  }) = _TypeStyle;

  @override
  List<String> get font;

  @override
  double get weight;

  @override
  double get size;

  @override
  double get tracking;

  @override
  double get lineHeight;

  @override
  double get wght;

  @override
  double get grad;

  @override
  double get wdth;

  @override
  double get rond;

  @override
  double get opsz;

  @override
  double get crsv;

  @override
  double get slnt;

  @override
  double get fill;

  @override
  double get hexp;

  @override
  TypeStyle copyWith({
    List<String>? font,
    double? weight,
    double? size,
    double? tracking,
    double? lineHeight,
    double? wght,
    double? grad,
    double? wdth,
    double? rond,
    double? opsz,
    double? crsv,
    double? slnt,
    double? fill,
    double? hexp,
  }) =>
      font != null ||
          weight != null ||
          size != null ||
          tracking != null ||
          lineHeight != null ||
          wght != null ||
          grad != null ||
          wdth != null ||
          rond != null ||
          opsz != null ||
          crsv != null ||
          slnt != null ||
          fill != null ||
          hexp != null
      ? TypeStyle.from(
          font: font ?? this.font,
          weight: weight ?? this.weight,
          size: size ?? this.size,
          tracking: tracking ?? this.tracking,
          lineHeight: lineHeight ?? this.lineHeight,
          wght: wght ?? this.wght,
          grad: grad ?? this.grad,
          wdth: wdth ?? this.wdth,
          rond: rond ?? this.rond,
          opsz: opsz ?? this.opsz,
          crsv: crsv ?? this.crsv,
          slnt: slnt ?? this.slnt,
          fill: fill ?? this.fill,
          hexp: hexp ?? this.hexp,
        )
      : this;

  @override
  TypeStyle mergeWith({
    List<String>? font,
    double? weight,
    double? size,
    double? tracking,
    double? lineHeight,
    double? wght,
    double? grad,
    double? wdth,
    double? rond,
    double? opsz,
    double? crsv,
    double? slnt,
    double? fill,
    double? hexp,
  }) =>
      font != null ||
          weight != null ||
          size != null ||
          tracking != null ||
          lineHeight != null ||
          wght != null ||
          grad != null ||
          wdth != null ||
          rond != null ||
          opsz != null ||
          crsv != null ||
          slnt != null ||
          fill != null ||
          hexp != null
      ? TypeStyle.from(
          font: font != null ? [...font, ...this.font] : this.font,
          weight: weight ?? this.weight,
          size: size ?? this.size,
          tracking: tracking ?? this.tracking,
          lineHeight: lineHeight ?? this.lineHeight,
          wght: wght ?? this.wght,
          grad: grad ?? this.grad,
          wdth: wdth ?? this.wdth,
          rond: rond ?? this.rond,
          opsz: opsz ?? this.opsz,
          crsv: crsv ?? this.crsv,
          slnt: slnt ?? this.slnt,
          fill: fill ?? this.fill,
          hexp: hexp ?? this.hexp,
        )
      : this;

  @override
  TypeStyle merge(TypeStylePartial? other) => other != null
      ? mergeWith(
          font: other.font,
          weight: other.weight,
          size: other.size,
          tracking: other.tracking,
          lineHeight: other.lineHeight,
          wght: other.wght,
          grad: other.grad,
          wdth: other.wdth,
          rond: other.rond,
          opsz: other.opsz,
          crsv: other.crsv,
          slnt: other.slnt,
          fill: other.fill,
          hexp: other.hexp,
        )
      : this;

  @override
  Map<String, double> get variableFontAxes => {
    _VariableFontAxes.wght: wght,
    _VariableFontAxes.grad: grad,
    _VariableFontAxes.wdth: wdth,
    _VariableFontAxes.rond: rond,
    _VariableFontAxes.opsz: opsz,
    _VariableFontAxes.crsv: crsv,
    _VariableFontAxes.slnt: slnt,
    _VariableFontAxes.fill: fill,
    _VariableFontAxes.hexp: hexp,
  };

  @override
  List<FontVariation> get fontVariations => [
    FontVariation(_VariableFontAxes.wght, wght),
    FontVariation(_VariableFontAxes.grad, grad),
    FontVariation(_VariableFontAxes.wdth, wdth),
    FontVariation(_VariableFontAxes.rond, rond),
    FontVariation(_VariableFontAxes.opsz, opsz),
    FontVariation(_VariableFontAxes.crsv, crsv),
    FontVariation(_VariableFontAxes.slnt, slnt),
    FontVariation(_VariableFontAxes.fill, fill),
    FontVariation(_VariableFontAxes.hexp, hexp),
  ];

  @override
  TextStyle toTextStyle({Color? color}) {
    final fontFamilyFallback = font.skip(1).toList();
    return TextStyle(
      inherit: true,
      fontFamily: font.first,
      fontFamilyFallback: fontFamilyFallback.isNotEmpty
          ? fontFamilyFallback
          : null,
      fontWeight: _closestFontWeightTo(weight),
      fontSize: size,
      height: lineHeight / size,
      letterSpacing: tracking,
      fontVariations: fontVariations,
      color: color,
    );
  }

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(IterableProperty("font", font))
      ..add(DoubleProperty("weight", weight))
      ..add(DoubleProperty("size", size))
      ..add(DoubleProperty("tracking", tracking))
      ..add(DoubleProperty("lineHeight", lineHeight))
      ..add(DoubleProperty("wght", wght))
      ..add(DoubleProperty("grad", grad))
      ..add(DoubleProperty("wdth", wdth))
      ..add(DoubleProperty("rond", rond))
      ..add(DoubleProperty("opsz", opsz))
      ..add(DoubleProperty("crsv", crsv))
      ..add(DoubleProperty("slnt", slnt))
      ..add(DoubleProperty("fill", fill))
      ..add(DoubleProperty("hexp", hexp));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is TypeStyle &&
          listEquals(font, other.font) &&
          weight == other.weight &&
          size == other.size &&
          tracking == other.tracking &&
          lineHeight == other.lineHeight &&
          wght == other.wght &&
          grad == other.grad &&
          wdth == other.wdth &&
          rond == other.rond &&
          opsz == other.opsz &&
          crsv == other.crsv &&
          slnt == other.slnt &&
          fill == other.fill &&
          hexp == other.hexp;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    Object.hashAll(font),
    weight,
    size,
    tracking,
    lineHeight,
    wght,
    grad,
    wdth,
    rond,
    opsz,
    crsv,
    slnt,
    fill,
    hexp,
  );

  static TypeStyle lerp(TypeStyle a, TypeStyle b, double t) {
    if (identical(a, b)) return a;
    return TypeStyle.from(
      font: t < 0.5 ? a.font : b.font,
      weight: lerpDouble(a.weight, b.weight, t)!,
      size: lerpDouble(a.size, b.size, t)!,
      lineHeight: lerpDouble(a.lineHeight, b.lineHeight, t)!,
      tracking: lerpDouble(a.tracking, b.tracking, t)!,
      wght: lerpDouble(a.wght, b.wght, t)!,
      grad: lerpDouble(a.grad, b.grad, t)!,
      wdth: lerpDouble(a.wdth, b.wdth, t)!,
      rond: lerpDouble(a.rond, b.rond, t)!,
      opsz: lerpDouble(a.opsz, b.opsz, t)!,
      crsv: lerpDouble(a.crsv, b.crsv, t)!,
      slnt: lerpDouble(a.slnt, b.slnt, t)!,
      fill: lerpDouble(a.fill, b.fill, t)!,
      hexp: lerpDouble(a.hexp, b.hexp, t)!,
    );
  }
}

@immutable
class _TypeStyle extends TypeStyle {
  const _TypeStyle({
    required this.font,
    required this.weight,
    required this.size,
    required this.tracking,
    required this.lineHeight,
    required this.wght,
    required this.grad,
    required this.wdth,
    required this.rond,
    required this.opsz,
    required this.crsv,
    required this.slnt,
    required this.fill,
    required this.hexp,
  });

  @override
  final List<String> font;

  @override
  final double weight;

  @override
  final double size;

  @override
  final double tracking;

  @override
  final double lineHeight;

  @override
  final double wght;

  @override
  final double grad;

  @override
  final double wdth;

  @override
  final double rond;

  @override
  final double opsz;

  @override
  final double crsv;

  @override
  final double slnt;

  @override
  final double fill;

  @override
  final double hexp;
}
