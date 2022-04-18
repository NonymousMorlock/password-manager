import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:at_base2e15/at_base2e15.dart';
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
  late FocusNode _titleFocusNode;
  final AppLogger _logger = AppLogger('ReportForm');
  bool _isReporting = false, _titleError = false;
  @override
  void initState() {
    _titleController = TextEditingController(text: 'Title of the report');
    _reportController = TextEditingController();
    _titleFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: EditableText(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
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
                maxLines: 30,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a report';
                  }
                  return null;
                },
                controller: _reportController,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _isReporting
                ? const AdaptiveLoading()
                : GestureDetector(
                    child: Text(
                      'Send',
                      style: TextStyle(
                        color: AppTheme.primary,
                      ),
                    ),
                    onTap: () async {
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
                      Report _report = Report(
                        id: _id,
                        title: _titleController.text,
                        content: _reportController.text,
                        createdAt: DateTime.now(),
                        from: context.read<UserData>().currentAtSign,
                        image: Base2e15.encode(
                            context.read<UserData>().currentProfilePic),
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
