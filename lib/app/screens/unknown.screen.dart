// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class UnknownRoute extends StatefulWidget {
  const UnknownRoute({Key? key}) : super(key: key);

  @override
  State<UnknownRoute> createState() => _UnknownRouteState();
}

class _UnknownRouteState extends State<UnknownRoute> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Unknown route'),
      ),
    );
  }
}
