// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:clipboard/clipboard.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/theme.dart';
import '../../provider/listeners/user_data.listener.dart';

class PasswordsPage extends StatefulWidget {
  const PasswordsPage({Key? key}) : super(key: key);
  @override
  State<PasswordsPage> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends State<PasswordsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: UserDataListener(
        builder: (BuildContext context, UserData userData) {
          return userData.passwords.isEmpty
              ? TextButton(
                  child: const Text('Passwords'),
                  onPressed: () async {
                    await AppServices.getPasswords();
                  },
                )
              : ListView.builder(
                  itemCount: userData.passwords.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Center(
                      child: SizedBox(
                        height: 70,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: ClipRRect(
                                      child: userData.passwords[i].favicon
                                                  .length ==
                                              2
                                          ? Center(
                                              child: Text(
                                                userData.passwords[i].favicon,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            )
                                          : Image.memory(
                                              Base2e15.decode(userData
                                                  .passwords[i].favicon),
                                              scale: 3,
                                              fit: BoxFit.scaleDown,
                                            ),
                                    ),
                                  ),
                                ),
                                Text(
                                  userData.passwords[i].name!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () async => FlutterClipboard.copy(
                                          userData.passwords[i].password!)
                                      .then(
                                    (_) => showToast(context, 'Copied',
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
                    );
                  },
                );
        },
      ),
    );
  }
}
