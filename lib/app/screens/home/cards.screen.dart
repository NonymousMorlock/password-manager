// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({Key? key}) : super(key: key);

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Cards'),
    );
  }
}
