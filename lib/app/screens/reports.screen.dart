// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:at_base2e15/at_base2e15.dart';

import '../../core/services/app.service.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/notifiers/user_data.dart';
import '../../meta/models/freezed/report.model.dart';
import '../provider/listeners/user_data.listener.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    Future<void>.microtask(() async {
      bool _inSync =
          await AppServices.sdkServices.atClientManager.syncService.isInSync();
      if (!_inSync) {
        AppServices.syncData();
      }
      await AppServices.getReports();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.transparent,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: UserDataListener(
              builder: (_, __) => SyncIndicator(size: 15),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            TablerIcons.chevron_left,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: () async {
          AppServices.syncData();
          await AppServices.getReports();
        },
        child: UserDataListener(
          builder: (BuildContext context, UserData userData) {
            return ListView(
              children: <Widget>[
                if (userData.reports.isEmpty)
                  const Center(
                    child: Text('No reports yet'),
                  )
                else
                  // sort reports by date
                  ...userData.reports.map(
                    (Report report) => Card(
                      child: ListTile(
                        title: Text(
                          report.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        isThreeLine: true,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(report.content.length <= 25
                                ? report.content
                                : report.content.substring(0, 25) + '...'),
                            Text(
                              'By: ' + report.from,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        leading: Image.memory(
                          Base2e15.decode(report.image),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text(report.title),
                                  content: Text(report.content),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ],
                                );
                              });
                        },
                        trailing: Text(
                            DateFormat().add_yMd().format(report.createdAt)),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
