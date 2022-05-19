// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../app/constants/global.dart';

class AdaptiveLoading extends StatelessWidget {
  const AdaptiveLoading({
    Key? key,
    this.strokeWidth,
    this.size,
  }) : super(key: key);
  final double? strokeWidth, size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: squareWidget(
        size ?? 20,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: strokeWidth ?? 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
