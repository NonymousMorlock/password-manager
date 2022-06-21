// 🐦 Flutter imports:

// 📦 Package imports:

import 'dart:convert';

import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../app/constants/global.dart';
import '../../app/constants/assets.dart';
import '../../app/constants/constants.dart';
import '../../app/provider/listeners/user_data.listener.dart';
import '../../core/services/app.service.dart';
import '../notifiers/theme.notifier.dart';
import '../notifiers/user_data.notifier.dart';
import 'toast.dart';

class AdminSheet extends StatefulWidget {
  const AdminSheet(
    this.context, {
    Key? key,
  }) : super(key: key);
  final BuildContext context;
  @override
  State<AdminSheet> createState() => _AdminSheetState();
}

class _AdminSheetState extends State<AdminSheet> {
  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () async => AppServices.getAdmins());
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final AtSignLogger _logger = AtSignLogger('AdminSheet');
  @override
  Widget build(BuildContext _) {
    return Container(
      height: 350,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          vSpacer(20),
          Text(
            'Admins',
            style: Theme.of(widget.context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          vSpacer(20),
          Expanded(
            child:
                UserDataListener(builder: (BuildContext __, UserData userData) {
              return ListView.builder(
                  itemCount: userData.admins.length,
                  itemBuilder: (BuildContext ___, int index) {
                    return Dismissible(
                      key: Key(userData.admins[index].id),
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
                          try {
                            http.Response res = await http.delete(
                                Uri.http(
                                    Constants.adminHost, Constants.adminPath),
                                headers: Constants.adminHeader,
                                body: jsonEncode(<Map<String, dynamic>>[
                                  <String, dynamic>{
                                    'isSuperAdmin':
                                        userData.admins[index].isSuperAdmin,
                                    'atSign': userData.admins[index].atSign,
                                  }
                                ]));
                            userData.admins.removeAt(index);
                            Navigator.pop(widget.context);
                            if (res.statusCode == 200 &&
                                jsonDecode(res.body)['success']) {
                              await HapticFeedback.heavyImpact();
                              showToast(widget.context, 'Admin deleted');
                            } else {
                              showToast(widget.context,
                                  'Status code ${res.statusCode} while deleting admin',
                                  isError: true);
                            }
                          } on Exception catch (e) {
                            _logger.severe('Failed to delete admin: $e');
                            Navigator.pop(widget.context);
                            showToast(widget.context, 'Failed to delete admin',
                                isError: true);
                          }
                        }
                      },
                      child: Card(
                        color: context.read<AppThemeNotifier>().isDarkTheme
                            ? const Color(0xff1E2228)
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: userData.admins[index].img == null
                              ? Image.asset(Assets.getRandomAvatar)
                              : Image.memory(
                                  Base2e15.decode(userData.admins[index].img!)),
                          title: Text(
                            userData.admins[index].name,
                            style: Theme.of(widget.context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            userData.admins[index].atSign,
                            style: Theme.of(widget.context).textTheme.caption!,
                          ),
                        ),
                      ),
                    );
                  });
            }),
          ),
        ],
      ),
    );
  }
}
