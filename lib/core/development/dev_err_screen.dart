// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

bool _isDebug = true;
Material codeErrorScreenBuilder(FlutterErrorDetails details) {
  return Material(
    child:
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Container(
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
                top: 0,
                right: 0,
                child: Switch.adaptive(
                  activeColor: Theme.of(context).primaryColor,
                  value: _isDebug,
                  onChanged: (bool value) {
                    setState(() {
                      _isDebug = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

/// Use this instead of [debugPrint] to print to the console.
void devLog(Object message, {DateTime? time}) => log(
      message.toString(),
      time: time,
      level: 400,
    );
