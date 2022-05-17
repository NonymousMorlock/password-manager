// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// 🌎 Project imports:
import '../../meta/notifiers/new_user.dart';
import '../../meta/notifiers/theme.dart';
import '../../meta/notifiers/user_data.dart';

class MultiProviders extends StatelessWidget {
  final Widget? child;
  const MultiProviders({
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<NewUser>(
          create: (BuildContext context) => NewUser(),
        ),
        ChangeNotifierProvider<UserData>(
          create: (BuildContext context) => UserData(),
        ),
        ChangeNotifierProvider<AppThemeNotifier>(
          create: (BuildContext context) => AppThemeNotifier(),
        ),
      ],
      child: child,
    );
  }
}
