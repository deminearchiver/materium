class Font {}

enum FontVariableAxis { wght, wdth, opsz, grad, rond }

class FontVariableAxisConstraint {
  const FontVariableAxisConstraint(this.axis, this.minValue, this.maxValue);

  final FontVariableAxis axis;
  final double minValue;
  final double maxValue;
}
