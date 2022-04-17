// 🎯 Dart imports:
import 'dart:math';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../app/constants/assets.dart';
import '../../app/constants/global.dart';
import '../../app/constants/theme.dart';
import 'toast.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({
    required this.cardNum,
    required this.cardName,
    required this.cvv,
    required this.expiry,
    required this.imageData,
    Key? key,
  }) : super(key: key);
  final String cardNum, cardName, cvv, expiry;
  final Uint8List imageData;
  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  double horizontalDrag = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails horizontal) {
        setState(() {
          horizontalDrag += horizontal.delta.dx;
          horizontalDrag %= 360;
        });
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY((horizontalDrag * -pi) / 180),
        alignment: Alignment.center,
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: <Color>[
                Color(0xff323232),
                Color.fromARGB(255, 28, 28, 28)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: horizontalDrag <= 90 || horizontalDrag >= 270
              ? cardFront()
              : Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: cardBack(),
                ),
        ),
      ),
    );
  }

  Widget cardFront() {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.memory(
                widget.imageData,
                height: 30,
              ),
              const Text(
                '|',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 10,
                  fontSize: 10,
                ),
              ),
              GestureDetector(
                onTap: () async => Clipboard.setData(
                  ClipboardData(text: widget.cardName),
                ).then(
                  (_) => showToast(context, 'Copied', width: 100),
                ),
                child: Text(
                  widget.cardName,
                  style: const TextStyle(
                    color: Colors.grey,
                    letterSpacing: 3,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Transform.rotate(
                angle: 0.9,
                child: const Icon(
                  TablerIcons.wifi,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          vSpacer(40),
          Image.asset(
            Assets.chip,
            height: 25,
          ),
          vSpacer(20),
          GestureDetector(
            onTap: () async => Clipboard.setData(
              ClipboardData(text: widget.cardNum),
            ).then((_) => showToast(context, 'Copied', width: 100)),
            child: Text(
              '**** **** **** ' + widget.cardNum.substring(15, 19),
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 18,
                wordSpacing: 15,
                shadows: const <Shadow>[
                  BoxShadow(
                    blurRadius: 2,
                    spreadRadius: 2,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardBack() {
    return Container(
      padding: const EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            color: Colors.grey[700],
          ),
          vSpacer(20),
          GestureDetector(
            onTap: () async => Clipboard.setData(
              ClipboardData(text: widget.cvv),
            ).then(
              (_) => showToast(context, 'Copied', width: 100),
            ),
            child: Container(
              width: 100,
              color: Colors.white,
              child: Text(
                '***',
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppTheme.grey,
                  fontSize: 18,
                  wordSpacing: 15,
                ),
              ),
            ),
          ),
          vSpacer(50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Expiry date ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.expiry,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
