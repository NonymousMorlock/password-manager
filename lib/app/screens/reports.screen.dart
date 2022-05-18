// 🐦 Flutter imports:

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:at_base2e15/at_base2e15.dart';
import 'package:file_saver/file_saver.dart';

import '../../core/services/app.service.dart';
import '../../meta/components/adaptive_loading.dart';
import '../../meta/components/report/stats.report.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/components/toast.dart';
import '../../meta/notifiers/theme.notifier.dart';
import '../../meta/notifiers/user_data.notifier.dart';
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
        title: Text(
          'Reports',
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: UserDataListener(
              builder: (_, __) => SyncIndicator(size: 15),
            ),
          ),
        ],
        leading: IconButton(
          icon: Icon(TablerIcons.chevron_left,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).backgroundColor,
        color: context.read<AppThemeNotifier>().primary,
        onRefresh: () async {
          AppServices.syncData();
          await AppServices.getReports();
        },
        child: UserDataListener(
          builder: (BuildContext context, UserData userData) {
            if (userData.reports.isEmpty) {
              if (userData.syncStatus != SyncStatus.success) {
                return const AdaptiveLoading();
              } else {
                return const Center(
                  child: Text('No reports found.'),
                );
              }
            } else {
              return ListView(
                children: <Widget>[
                  if (userData.reports.isNotEmpty)
                    ...userData.reports.map(
                      (Report report) => Card(
                        color: context.read<AppThemeNotifier>().isDarkTheme
                            ? const Color(0xff1E2228)
                            : Colors.white,
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
                              Text(
                                DateFormat().add_yMd().format(report.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
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
                                return ReportStats(report);
                              },
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(TablerIcons.file_download),
                            onPressed: () async {
                              String data = await FileSaver.instance.saveFile(
                                  'report_${report.from}_${DateFormat().add_yMd().format(report.createdAt).replaceAll('/', '-')}',
                                  Base2e15.decode(report.logFileData!),
                                  'log');
                              showToast(context, 'Log file saved to $data');
                              print('Log file saved to $data');
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
