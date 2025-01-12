import 'package:flutter/cupertino.dart';

class Clipping extends StatelessWidget {
  const Clipping({
    super.key,
    required this.child,
    required this.localPosition,
    required this.radius,
  });

  final Widget child;
  final Offset localPosition;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CircleClipper(radius: radius, localPosition: localPosition),
      child: child,
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final double radius;
  final Offset localPosition;

  CircleClipper({
    super.reclip,
    required this.radius,
    required this.localPosition,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    path.addOval(Rect.fromCircle(center: localPosition, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
