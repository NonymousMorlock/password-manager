// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../app/constants/global.dart';

class AdaptiveLoading extends StatelessWidget {
  const AdaptiveLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: squareWidget(
        20,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
