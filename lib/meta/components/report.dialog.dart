// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class ReportToDevelopers extends StatefulWidget {
  const ReportToDevelopers({Key? key}) : super(key: key);

  @override
  State<ReportToDevelopers> createState() => _ReportToDevelopersState();
}

class _ReportToDevelopersState extends State<ReportToDevelopers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 120,
        width: 350,
        color: Colors.white,
        child: const Text('Report to developers'),
      ),
    );
  }
}
