// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../app/constants/global.dart';
import '../../../app/constants/keys.dart';
import '../../../core/services/app.service.dart';
import '../../extensions/logger.ext.dart';
import '../../notifiers/theme.notifier.dart';
import 'color_picker.dart';

class ThemePicker extends StatefulWidget {
  const ThemePicker({
    Key? key,
  }) : super(key: key);

  @override
  State<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  final AppLogger _logger = AppLogger('Theme Picker');

  late bool _isDarkTheme;

  final List<Color> _themeColors = <Color>[
    Colors.green,
    Colors.amber,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () {
      setState(
          () => _isDarkTheme = context.read<AppThemeNotifier>().isDarkTheme);
    });
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
              'Choose a Theme',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            vSpacer(10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
              child: Wrap(spacing: 30, runSpacing: 30, children: <Widget>[
                ..._themeColors.map<Widget>((Color color) {
                  color is MaterialColor ? color = color.shade500 : null;
                  return ColorPicker(
                    color: color,
                    isSelected:
                        color == context.read<AppThemeNotifier>().primary,
                    onColorChanged: () async {
                      context.read<AppThemeNotifier>().primary = color;
                      bool _themeUpdated = await AppServices.sdkServices.put(
                          Keys.themeKey
                            ..value!.value =
                                color.value.toRadixString(16).padLeft(8, '0'));
                      if (_themeUpdated) {
                        _logger.finer('Theme updated to $color');
                      } else {
                        _logger.severe('Failed to updated theme to $color');
                      }
                    },
                  );
                }).toList(),
                AnimatedContainer(
                  duration: const Duration(seconds: 0),
                  height: 30,
                  width: 30,
                  child: Center(
                    child: IconButton(
                      onPressed: () async {
                        setState(() => _isDarkTheme = !_isDarkTheme);
                        context.read<AppThemeNotifier>().isDarkTheme =
                            _isDarkTheme;
                        await AppServices.sdkServices.put(Keys.isDarkTheme
                          ..value?.value =
                              context.read<AppThemeNotifier>().isDarkTheme);
                      },
                      icon: Icon(context.watch<AppThemeNotifier>().isDarkTheme
                          ? TablerIcons.sun
                          : TablerIcons.moon),
                    ),
                  ),
                ),
              ]),
            ),
            vSpacer(20),
          ],
        ),
      ),
    );
  }
}
