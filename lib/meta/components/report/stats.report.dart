import 'package:flutter/material.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:at_base2e15/at_base2e15.dart';
import '../../../app/constants/global.dart';
import '../../models/freezed/report.model.dart';

class ReportStats extends StatefulWidget {
  const ReportStats(this.report, {Key? key}) : super(key: key);
  final Report report;
  @override
  State<ReportStats> createState() => _ReportStatsState();
}

class _ReportStatsState extends State<ReportStats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(150),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(10),
                child: Image(
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  image: Image.memory(
                    Base2e15.decode(widget.report.image),
                  ).image,
                ),
              ),
            ),
            vSpacer(20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              constraints: const BoxConstraints(
                maxWidth: 300,
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          widget.report.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            TablerIcons.x,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: Navigator.of(context).pop,
                        ),
                      ],
                    ),
                    vSpacer(15),
                    Text(widget.report.content),
                    vSpacer(15),
                    Text(
                      'Experience: ${widget.report.experience}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
