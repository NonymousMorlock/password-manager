// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class CircleTabIndicator extends Decoration {
  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);
  final BoxPainter _painter;

  @override
  BoxPainter createBoxPainter([Function()? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  final Paint _paint;
  final double radius;
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    Offset circleOffset = offset + Offset(40, 45 - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
