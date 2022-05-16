import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:at_base2e15/at_base2e15.dart';
import 'package:path/path.dart' as p;

import '../../../app/constants/constants.dart';
import '../../../app/constants/global.dart';
import '../../../app/constants/theme.dart';
import '../../../core/services/app.service.dart';
import '../../../core/services/passman.env.dart';
import '../../extensions/logger.ext.dart';
import '../../models/freezed/report.model.dart';
import '../../models/key.model.dart';
import '../../models/value.model.dart';
import '../../notifiers/user_data.dart';
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
      _emoji5 = false;
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
    return Padding(
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
                color: _titleError ? Colors.red : Colors.black,
              ),
              backgroundCursorColor: Colors.transparent,
              controller: _titleController,
              cursorColor: AppTheme.primary,
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
                color: Colors.grey[200],
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
                experience: '🤬',
                onTap: () {
                  setState(() {
                    _emoji1 = !_emoji1;
                    _emoji2 = false;
                    _emoji3 = false;
                    _emoji4 = false;
                    _emoji5 = false;
                    if (_experience == '🤬') {
                      _experience = null;
                    } else {
                      _experience = '🤬';
                    }
                  });
                },
              ),
              RatingExperience(
                isSelected: _emoji2,
                experience: '☹️',
                onTap: () {
                  setState(() {
                    _emoji1 = false;
                    _emoji2 = !_emoji2;
                    _emoji3 = false;
                    _emoji4 = false;
                    _emoji5 = false;
                    if (_experience == '☹️') {
                      _experience = null;
                    } else {
                      _experience = '☹️';
                    }
                  });
                },
              ),
              RatingExperience(
                isSelected: _emoji3,
                experience: '😔',
                onTap: () {
                  setState(() {
                    _emoji1 = false;
                    _emoji2 = false;
                    _emoji3 = !_emoji3;
                    _emoji4 = false;
                    _emoji5 = false;
                    if (_experience == '😔') {
                      _experience = null;
                    } else {
                      _experience = '😔';
                    }
                  });
                },
              ),
              RatingExperience(
                isSelected: _emoji4,
                experience: '🙂',
                onTap: () {
                  setState(() {
                    _emoji1 = false;
                    _emoji2 = false;
                    _emoji3 = false;
                    _emoji4 = !_emoji4;
                    _emoji5 = false;
                    if (_experience == '🙂') {
                      _experience = null;
                    } else {
                      _experience = '🙂';
                    }
                  });
                },
              ),
              RatingExperience(
                isSelected: _emoji5,
                experience: '😍',
                onTap: () {
                  setState(() {
                    _emoji1 = false;
                    _emoji2 = false;
                    _emoji3 = false;
                    _emoji4 = false;
                    _emoji5 = !_emoji5;
                    if (_experience == '😍') {
                      _experience = null;
                    } else {
                      _experience = '😍';
                    }
                  });
                },
              ),
            ],
          ),
          vSpacer(15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _isReporting
                ? const AdaptiveLoading()
                : TextButton(
                    child: Text(
                      'Send',
                      style: TextStyle(
                        color: AppTheme.primary,
                      ),
                    ),
                    onPressed: () async {
                      _titleFocusNode.unfocus();
                      _reportContentFocus.unfocus();
                      if (_titleController.text.isEmpty ||
                          _titleController.text.toLowerCase() ==
                              'title of the report') {
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
                      String _id = Constants.uuid;
                      String _logsPath = p.join(
                          (await getApplicationSupportDirectory()).path,
                          'logs');
                      Uint8List? _logFileBytes;
                      String date =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      for (FileSystemEntity a
                          in Directory(_logsPath).listSync()) {
                        if (a is File) {
                          if (a.path.split(Platform.pathSeparator).last ==
                              'passman_$date.log') {
                            _logFileBytes = await File(a.path).readAsBytes();
                          }
                        }
                      }
                      await AppServices.readFilesAsBytes(
                          p.join(_logsPath, 'passman_$date.log'));
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
                      );
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
