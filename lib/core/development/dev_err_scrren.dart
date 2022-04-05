// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

bool _isDebug = true;
Widget codeErrorScreenBuilder(FlutterErrorDetails details) {
  return Material(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      // color: Colors.red,
      child: Center(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'assets/images/error.png',
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Error',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isDebug
                        ? details.exceptionAsString() +
                            '\n' +
                            details.stack.toString()
                        : details.exceptionAsString(),
                    textAlign: _isDebug ? TextAlign.left : TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Switch(
                value: _isDebug,
                onChanged: (bool value) {
                  _isDebug = value;
                },
              ),
              bottom: 0,
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Use this instead of [debugPrint] to print to the console.
void devLog(Object message, {DateTime? time}) => log(
      message.toString(),
      time: time,
      level: 400,
    );
