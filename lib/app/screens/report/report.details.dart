import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:at_base2e15/at_base2e15.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:tabler_icons/tabler_icons.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/extensions/logger.ext.dart';
import '../../../meta/models/freezed/report.model.dart';
import '../../../meta/notifiers/theme.notifier.dart';
import '../../constants/global.dart';

class ReportDetails extends StatefulWidget {
  const ReportDetails({Key? key}) : super(key: key);

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  Report? report;
  bool _saving = false;
  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () async {
      setState(
          () => report = ModalRoute.of(context)!.settings.arguments as Report?);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          icon: Icon(TablerIcons.chevron_left,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SyncIndicator(size: 15),
          )
        ],
      ),
      body: report == null
          ? const Center(child: AdaptiveLoading())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Hero(
                              tag: 'report_image_${report!.id}',
                              child: Image(
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                image: Image.memory(
                                  Base2e15.decode(report!.image),
                                ).image,
                              ),
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                report!.from,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              vSpacer(10),
                              RichText(
                                text: TextSpan(
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: 'Created: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: DateFormat()
                                          .format(report!.createdAt),
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          height: 20,
                          thickness: 1,
                          color: Theme.of(context).dividerColor,
                          endIndent: 20,
                          indent: 20,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Report Id : ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: report!.id,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Divider(
                          height: 20,
                          thickness: 1,
                          color: Theme.of(context).dividerColor,
                          endIndent: 20,
                          indent: 20,
                        ),
                      ),
                      Text(
                        report!.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      vSpacer(20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            report!.content.isEmpty
                                ? 'Not provided'
                                : report!.content,
                            textAlign: report!.content.length > 53
                                ? TextAlign.start
                                : TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                      vSpacer(20),
                      Text(
                        'Experience',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      vSpacer(20),
                      Text(
                        report!.experience ?? 'Not provided',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            fontSize: report!.experience == null ? 14 : 40,
                            height: 1),
                      ),
                      vSpacer(20),
                      Text(
                        'Device Info',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      vSpacer(20),
                      _DeviceInfo(report!.deviceInfo),
                      vSpacer(20),
                      Text(
                        'Logs file',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      vSpacer(20),
                      _saving
                          ? squareWidget(48, child: const AdaptiveLoading())
                          : Tooltip(
                              message: '${report?.from ?? 'Unknown'} Logs',
                              child: TextButton(
                                onPressed: () async {
                                  setState(() => _saving = true);
                                  String _logsPath = p.join(
                                      (await getApplicationSupportDirectory())
                                          .path,
                                      'logs',
                                      'report_${report!.from}_${DateFormat().add_yMd().format(report!.createdAt).replaceAll('/', '-')}.log');
                                  Uint8List _bytes =
                                      Base2e15.decode(report!.logFileData!);
                                  File _file = File(_logsPath);
                                  await _file.writeAsBytes(_bytes);
                                  ShareResult shareResult =
                                      await Share.shareFilesWithResult(
                                          <String>[_logsPath],
                                          sharePositionOrigin: Rect.fromLTWH(
                                              0,
                                              0,
                                              MediaQuery.of(context).size.width,
                                              MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2));
                                  bool _saved = shareResult.status ==
                                      ShareResultStatus.success;
                                  setState(() => _saving = false);
                                  AppLogger('ReportDetails').finer(
                                      'Log file ${_saved ? 'saved' : 'not saved'}');
                                  showToast(context,
                                      'Log file ${_saved ? 'saved' : 'not saved'}',
                                      isError: !_saved);
                                },
                                child: const Text('Download Logs'),
                                style: Theme.of(context)
                                    .textButtonTheme
                                    .style
                                    ?.copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        context
                                            .read<AppThemeNotifier>()
                                            .primary,
                                      ),
                                    ),
                              ),
                            ),
                      vSpacer(40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DeviceInfo extends StatelessWidget {
  const _DeviceInfo(
    this.deviceInfo, {
    Key? key,
  }) : super(key: key);

  final Map<String, dynamic>? deviceInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: deviceInfo == null
          ? const Text('Not provided')
          : SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ...deviceInfo!.entries.map(
                    (MapEntry<String, dynamic> e) => RichText(
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: e.key + '   :   ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: e.value.toString() + '\n',
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(fontSize: 14),
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
