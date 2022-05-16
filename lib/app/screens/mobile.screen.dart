import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MobileDeviceScreen extends StatefulWidget {
  const MobileDeviceScreen({Key? key}) : super(key: key);

  @override
  State<MobileDeviceScreen> createState() => _MobileDeviceScreenState();
}

class _MobileDeviceScreenState extends State<MobileDeviceScreen> {
  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () async {
      await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('Incompatible device'),
              content: const Text(
                  'The device you use is not supported by this app. Please try using any other mobile devices.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Exit'),
                  onPressed: () =>
                      Platform.isIOS ? exit(0) : SystemNavigator.pop(),
                ),
              ],
            );
          });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Please use mobile device.'),
      ),
    );
  }
}
