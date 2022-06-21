// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../../core/services/app.service.dart';
import '../../../../meta/components/toast.dart';
import '../../../../meta/notifiers/theme.notifier.dart';
import '../../../../meta/notifiers/user_data.notifier.dart';
import '../../../constants/global.dart';
import '../../../constants/theme.dart';
import '../../../provider/listeners/user_data.listener.dart';

class PasswordsPage extends StatefulWidget {
  final BuildContext context;
  const PasswordsPage(this.context, {Key? key}) : super(key: key);
  @override
  State<PasswordsPage> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends State<PasswordsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RefreshIndicator(
        backgroundColor: Theme.of(context).backgroundColor,
        color: context.read<AppThemeNotifier>().primary,
        onRefresh: () async => AppServices.getPasswords(),
        child: UserDataListener(
          builder: (BuildContext context, UserData userData) {
            return userData.passwords.isEmpty
                ? const Text('No passwords saved yet')
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: userData.passwords.length,
                    padding: const EdgeInsets.all(15.0),
                    itemBuilder: (BuildContext context, int i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Dismissible(
                          key: Key(userData.passwords[i].name),
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
                              bool _isDeleted = await AppServices.sdkServices
                                  .delete(userData.passwords[i].id);
                              if (_isDeleted) {
                                userData.passwords.removeAt(i);
                                await HapticFeedback.heavyImpact();
                                await AppServices.getPasswords();
                                showToast(
                                    widget.context, 'Password deleted successfully');
                              }
                            }
                          },
                          child: Center(
                            child: SizedBox(
                              height: 70,
                              child: Card(
                                color:
                                    context.read<AppThemeNotifier>().isDarkTheme
                                        ? const Color(0xff1E2228)
                                        : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Center(
                                        child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: userData.passwords[i].favicon
                                                        .length ==
                                                    2
                                                ? Center(
                                                    child: Text(
                                                      userData
                                                          .passwords[i].favicon,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  )
                                                : Image.memory(
                                                    Base2e15.decode(userData
                                                        .passwords[i].favicon),
                                                    height: 30,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      hSpacer(20),
                                      Text(
                                        userData.passwords[i].name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async =>
                                            Clipboard.setData(ClipboardData(
                                                    text: userData
                                                        .passwords[i].password))
                                                .then(
                                          (_) => showToast(widget.context, 'Copied',
                                              width: 100),
                                        ),
                                        icon: Icon(
                                          TablerIcons.copy,
                                          color: AppTheme.disabled,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
