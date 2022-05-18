// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../notifiers/user_data.notifier.dart';

class SyncIndicator extends StatelessWidget {
  SyncIndicator({
    this.child,
    this.size = 15,
    Key? key,
  })  : assert(size! >= 45 || child == null,
            'Size must be greater than 45 if child is not null'),
        super(key: key);
  final Widget? child;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.loose,
      children: <Widget>[
        ChangeNotifierProvider<UserData>.value(
          value: context.read<UserData>(),
          builder: (BuildContext context, _) => Consumer<UserData>(
            builder: (BuildContext context, UserData value, Widget? _) =>
                AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: child != null ? 45 : size,
              width: child != null ? 45 : size,
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: child == null ? syncColors(value) : null,
                border: Border.all(
                  color: syncColors(value),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(2 * size!),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Color syncColors(UserData value) => value.syncStatus == SyncStatus.notStarted
      ? Colors.lightBlueAccent
      : value.syncStatus == SyncStatus.started
          ? Colors.yellow[600]!
          : value.syncStatus == SyncStatus.success
              ? Colors.transparent
              : Colors.red;
}
