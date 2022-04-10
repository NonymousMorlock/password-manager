// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import '../../app/constants/theme.dart';

class FilledTextField extends StatelessWidget {
  const FilledTextField({
    required this.onChanged,
    this.inputFormatters,
    this.controller,
    this.hint,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.prefix,
    this.width,
    this.textStyle,
    this.obsecureText = false,
    Key? key,
  }) : super(key: key);
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? hint;
  final double? width;
  final bool obsecureText;
  final Widget? prefix;
  final TextStyle? textStyle;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 300,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.disabled.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obsecureText,
        autocorrect: false,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          isDense: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: hint,
          prefix: prefix,
        ),
        style: textStyle,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }
}
