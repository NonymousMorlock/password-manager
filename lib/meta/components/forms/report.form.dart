// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../app/constants/constants.dart';
import '../../../app/constants/global.dart';
import '../../../app/constants/theme.dart';
import '../../../core/services/app.service.dart';
import '../../../core/services/passman.env.dart';
import '../../extensions/logger.ext.dart';
import '../../models/freezed/report.model.dart';
import '../../models/key.model.dart';
import '../../models/value.model.dart';
import '../../notifiers/user_data.notifier.dart';
import '../adaptive_loading.dart';
import '../toast.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({
    Key? key,
  }) : super(key: key);

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  late TextEditingController _titleController, _reportController;
  late FocusNode _titleFocusNode, _reportContentFocus;
  final AppLogger _logger = AppLogger('ReportForm');
  bool _isReporting = false,
      _titleError = false,
      _emoji1 = false,
      _emoji2 = false,
      _emoji3 = false,
      _emoji4 = false,
      _emoji5 = false,
      _shareLogs = true;
  String? _experience;
  @override
  void initState() {
    _titleController = TextEditingController(text: 'Title of the report');
    _reportController = TextEditingController();
    _reportContentFocus = FocusNode();
    _titleFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _reportContentFocus.dispose();
    _titleController.dispose();
    _reportController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: EditableText(
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _titleError
                      ? Colors.red
                      : Theme.of(context).textTheme.bodyText1?.color,
                ),
                backgroundCursorColor: Colors.transparent,
                controller: _titleController,
                cursorColor: Theme.of(context).primaryColor,
                focusNode: _titleFocusNode,
                onChanged: (String value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      _titleError == false;
                    }
                  });
                },
              ),
            ),
            vSpacer(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                height: 100,
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: ,
                ),
                child: TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 30,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a report';
                    }
                    return null;
                  },
                  controller: _reportController,
                  focusNode: _reportContentFocus,
                  decoration: InputDecoration(
                    fillColor: AppTheme.grey.withOpacity(0.2),
                    hintText:
                        'Oops, Sorry to get you here. Please tell us what happened.',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (String value) {
                    if (_titleFocusNode.hasFocus) {
                      _titleFocusNode.unfocus();
                    }
                  },
                ),
              ),
            ),
            vSpacer(15),
            const Text(
              'Rate your experience',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            vSpacer(15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RatingExperience(
                  isSelected: _emoji1,
                  experience: '\u{1F92C}',
                  onTap: () {
                    setState(() {
                      _emoji1 = !_emoji1;
                      _emoji2 = false;
                      _emoji3 = false;
                      _emoji4 = false;
                      _emoji5 = false;
                      if (_experience == '\u{1F92C}') {
                        _experience = null;
                      } else {
                        _experience = '\u{1F92C}';
                      }
                    });
                  },
                ),
                RatingExperience(
                  isSelected: _emoji2,
                  experience: '\u{1F641}',
                  onTap: () {
                    setState(() {
                      _emoji1 = false;
                      _emoji2 = !_emoji2;
                      _emoji3 = false;
                      _emoji4 = false;
                      _emoji5 = false;
                      if (_experience == '\u{1F641}') {
                        _experience = null;
                      } else {
                        _experience = '\u{1F641}';
                      }
                    });
                  },
                ),
                RatingExperience(
                  isSelected: _emoji3,
                  experience: '\u{1F614}',
                  onTap: () {
                    setState(() {
                      _emoji1 = false;
                      _emoji2 = false;
                      _emoji3 = !_emoji3;
                      _emoji4 = false;
                      _emoji5 = false;
                      if (_experience == '\u{1F614}') {
                        _experience = null;
                      } else {
                        _experience = '\u{1F614}';
                      }
                    });
                  },
                ),
                RatingExperience(
                  isSelected: _emoji4,
                  experience: '\u{1F642}',
                  onTap: () {
                    setState(() {
                      _emoji1 = false;
                      _emoji2 = false;
                      _emoji3 = false;
                      _emoji4 = !_emoji4;
                      _emoji5 = false;
                      if (_experience == '\u{1F642}') {
                        _experience = null;
                      } else {
                        _experience = '\u{1F642}';
                      }
                    });
                  },
                ),
                RatingExperience(
                  isSelected: _emoji5,
                  experience: '\u{1F60D}',
                  onTap: () {
                    setState(() {
                      _emoji1 = false;
                      _emoji2 = false;
                      _emoji3 = false;
                      _emoji4 = false;
                      _emoji5 = !_emoji5;
                      if (_experience == '\u{1F60D}') {
                        _experience = null;
                      } else {
                        _experience = '\u{1F60D}';
                      }
                    });
                  },
                ),
              ],
            ),
            vSpacer(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: <Widget>[
                  // checkbox
                  Checkbox(
                    value: _shareLogs,
                    activeColor: Theme.of(context).primaryColor,
                    splashRadius: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(4),
                      ),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        _shareLogs = value!;
                      });
                    },
                  ),
                  Text(
                    'Share my device info and logs file.\n(Check this if you are reporting an issue)',
                    overflow: TextOverflow.visible,
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                ],
              ),
            ),
            vSpacer(15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: _isReporting
                  ? squareWidget(48, child: const AdaptiveLoading())
                  : TextButton(
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onPressed: () async {
                        _titleFocusNode.unfocus();
                        _reportContentFocus.unfocus();
                        if (_titleController.text.isEmpty ||
                            _titleController.text.toLowerCase() ==
                                'title of the report' ||
                            _titleController.text.toLowerCase() ==
                                'change me...') {
                          _logger.severe('Title is empty');
                          setState(() {
                            _titleController.text = 'Change me...';
                            _titleError = true;
                            _isReporting = false;
                          });
                          _reportController.clear();
                          return;
                        }
                        setState(() => _isReporting = true);
                        Uint8List? _logFileBytes;
                        Map<String, dynamic> _deviceInfo = <String, dynamic>{};
                        String _id = Constants.uuid;
                        if (_shareLogs) {
                          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                          Map<String, dynamic> _dd =
                              (await deviceInfo.deviceInfo).toMap();
                          _deviceInfo.clear();
                          _deviceInfo['Device Name'] = _dd['name'];
                          _deviceInfo['Device Model'] = _dd['model'];
                          _deviceInfo['Operating system'] = _dd['systemName'];
                          _deviceInfo['OS Version'] = _dd['systemVersion'];
                          _deviceInfo['Device Architecture'] =
                              _dd['utsname']['machine'];
                          _deviceInfo['Is physical device'] =
                              _dd['isPhysicalDevice'];
                          String _logsPath = p.join(
                              (await getApplicationSupportDirectory()).path,
                              'logs');
                          String date =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          for (FileSystemEntity a
                              in Directory(_logsPath).listSync()) {
                            if (a is File) {
                              if (a.path.split(Platform.pathSeparator).last ==
                                  'passman_$date.log') {
                                _logFileBytes =
                                    await File(a.path).readAsBytes();
                              }
                            }
                          }
                        }
                        Report _report = Report(
                            id: _id,
                            title: _titleController.text,
                            content: _reportController.text,
                            createdAt: DateTime.now(),
                            from: context.read<UserData>().currentAtSign,
                            image: Base2e15.encode(
                                context.read<UserData>().currentProfilePic),
                            experience: _experience,
                            logFileData: _logFileBytes == null
                                ? null
                                : Base2e15.encode(_logFileBytes),
                            deviceInfo: _deviceInfo);
                        PassKey _reportKey = PassKey(
                          key: 'report_' + _id,
                          sharedBy: AppServices.sdkServices.currentAtSign,
                          sharedWith: PassmanEnv.reportAtsign,
                          isCached: true,
                          ttr: 864000,
                          value: Value(
                            value: _report.toJson(),
                            type: 'Report',
                            labelName: 'Report',
                          ),
                        );
                        bool _reported =
                            await AppServices.sdkServices.put(_reportKey);
                        setState(() {
                          _titleError = false;
                          _isReporting = false;
                        });
                        if (_reported) {
                          _reportController.clear();
                          Navigator.pop(context);
                          showToast(context, 'Reported successfully');
                        }
                      },
                    ),
            ),
            vSpacer(25),
          ],
        ),
      ),
    );
  }
}

class RatingExperience extends StatefulWidget {
  const RatingExperience(
      {required this.onTap,
      required this.isSelected,
      required this.experience,
      Key? key})
      : super(key: key);
  final GestureTapCallback? onTap;
  final bool isSelected;
  final String experience;

  @override
  State<RatingExperience> createState() => _RatingExperienceState();
}

class _RatingExperienceState extends State<RatingExperience> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        height: 40,
        width: 40,
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.isSelected
              ? AppTheme.grey.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: AnimatedOpacity(
          opacity: widget.isSelected ? 1 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Text(
              widget.experience,
              style: const TextStyle(fontSize: 25),
            ),
          ),
        ),
      ),
    );
  }
}
