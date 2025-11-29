import 'package:material/src/material/flutter.dart';

class Button extends StatefulWidget {
  const Button({super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  final Tween<double> _elevationTween = Tween<double>();
  final Tween<ShapeBorder?> _shapeTween = ShapeBorderTween();

  late AnimationController _shapeAnimationController;

  late Animation<double> _elevationAnimation;
  late Animation<ShapeBorder?> _shapeAnimation;
  late Animation<Color?> _containerColorAnimation;
  late Animation<Color?> _contentColorAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Button oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
