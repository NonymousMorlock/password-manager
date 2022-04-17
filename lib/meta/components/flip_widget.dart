// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class Flip extends StatefulWidget {
  const Flip({
    required this.front,
    required this.back,
    required this.isFront,
    Key? key,
  }) : super(key: key);
  final bool isFront;
  final Widget front;
  final Widget back;
  @override
  State<Flip> createState() => _FlipState();
}

class _FlipState extends State<Flip> {
  double _vertical = 0;
  bool isFront = true;
  @override
  void initState() {
    isFront = widget.isFront;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        setState(() {
          _vertical += details.delta.dx;
          _vertical %= 360;
          if (_vertical <= 90 || _vertical >= 270) {
            setState(() => isFront = true);
          } else {
            setState(() => isFront = false);
          }
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY((_vertical * -pi) / 180),
        alignment: Alignment.center,
        child: isFront
            ? widget.front
            : Transform(
                transform: Matrix4.identity()..rotateY(pi),
                alignment: Alignment.center,
                child: widget.back),
      ),
    );
  }
}
