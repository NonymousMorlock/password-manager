// 🐦 Flutter imports:
import 'dart:convert';

import 'package:flutter/material.dart';

// 📦 Package imports:

// 🌎 Project imports:
import '../../../app/constants/global.dart';
import '../../app/constants/assets.dart';
import '../../app/provider/listeners/user_data.listener.dart';
import '../../core/services/app.service.dart';
import '../extensions/logger.ext.dart';
import '../models/freezed/admin.model.dart';
import '../notifiers/user_data.notifier.dart';

class AdminSheet extends StatefulWidget {
  const AdminSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminSheet> createState() => _AdminSheetState();
}

class _AdminSheetState extends State<AdminSheet> {
  final AppLogger _logger = AppLogger('AdminSheet');

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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            vSpacer(10),
            Text(
              'Add Admins',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            vSpacer(10),
            UserDataListener(
                builder: (BuildContext context, UserData userData) {
              return Column(
                children: <Widget>[
                  ...userData.admins.map((Admin a) {
                    return ListTile(
                      leading: a.img == null
                          ? Image.asset(Assets.getRandomAvatar)
                          : Image.memory(base64Decode(a.img!)),
                      title: Text(
                        a.name,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Text(
                        a.atSign,
                        style: Theme.of(context).textTheme.caption!,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                      ),
                    );
                  }),
                ],
              );
              // return ListView.builder(
              //     itemCount: userData.admins.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       return ListTile(
              //         title: Text(
              //           userData.admins[index].name,
              //           style: Theme.of(context).textTheme.headline6!.copyWith(
              //                 fontWeight: FontWeight.bold,
              //               ),
              //         ),
              //         subtitle: Text(
              //           userData.admins[index].atSign,
              //           style: Theme.of(context).textTheme.headline6!.copyWith(
              //                 fontWeight: FontWeight.bold,
              //               ),
              //         ),
              //         trailing: IconButton(
              //           icon: const Icon(Icons.delete),
              //           onPressed: () {},
              //         ),
              //       );
              //     });
            }),
            vSpacer(20),
          ],
        ),
      ),
    );
  }
}
