// 🐦 Flutter imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:flutter/material.dart';
// 📦 Package imports:
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/models/freezed/report.model.dart';
import '../../../meta/notifiers/theme.notifier.dart';
import '../../../meta/notifiers/user_data.notifier.dart';
import '../../constants/page_route.dart';
import '../../provider/listeners/user_data.listener.dart';

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
        AppServices.syncData(AppServices.getReports);
      } else {
        await AppServices.getReports();
      }
    });
    super.initState();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          AppServices.syncData(AppServices.getReports);
        },
        child: UserDataListener(
          builder: (BuildContext context, UserData userData) {
            if (userData.reports.isEmpty) {
              return const Center(child: Text('No reports saved yet'));
            } else {
              return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: userData.reports.length,
                  padding: const EdgeInsets.all(15.0),
                  itemBuilder: (BuildContext context, int i) {
                    Report report = userData.reports[i];
                    return Dismissible(
                      key: Key(report.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.transparent,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Icon(
                            TablerIcons.trash,
                            color: Colors.red,
                          ),
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      onDismissed: (DismissDirection direction) async {
                        if (direction == DismissDirection.endToStart) {
                          bool _isDeleted =
                              await AppServices.sdkServices.delete(report.id);
                          if (_isDeleted) {
                            userData.reports
                                .removeAt(userData.reports.indexOf(report));
                            await HapticFeedback.heavyImpact();
                            await AppServices.getReports();
                            showToast(_scaffoldKey.currentContext, 'Report deleted successfully');
                          }
                        }
                      },
                      child: Card(
                        color: context.read<AppThemeNotifier>().isDarkTheme
                            ? const Color(0xff1E2228)
                            : Colors.white,
                        child: ListTile(
                          title: Text(
                            report.title.length <= 25
                                ? report.title
                                : report.title.substring(0, 25) + '...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'By: ' + report.from,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Hero(
                              tag: 'report_image_${report.id}',
                              child: Image(
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                image: Image.memory(
                                  Base2e15.decode(report.image),
                                ).image,
                              ),
                            ),
                          ),
                          trailing: report.experience == null
                              ? null
                              : Text(
                                  report.experience!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 26),
                                ),
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, PageRouteNames.reportDetails,
                                arguments: report);
                          },
                        ),
                      ),
                    );
                  });
            }
          },
        ),
      ),
    );
  }
}
