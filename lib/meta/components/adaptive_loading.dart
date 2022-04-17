// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../app/constants/global.dart';

class AdaptiveLoading extends StatelessWidget {
  const AdaptiveLoading({
    Key? key,
    this.strokeWidth,
  }) : super(key: key);
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: squareWidget(
        20,
        child:
            CircularProgressIndicator.adaptive(strokeWidth: strokeWidth ?? 2),
      ),
    );
  }
}
