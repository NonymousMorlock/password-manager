// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../../app/constants/global.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key? key,
    required this.color,
    this.onColorChanged,
    this.isSelected = false,
  }) : super(key: key);
  final GestureTapCallback? onColorChanged;
  final Color color;
  final bool isSelected;
  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onColorChanged,
      child: AnimatedContainer(
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color: widget.isSelected ? widget.color : Colors.transparent,
            width: 3,
          ),
        ),
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
          child: squareWidget(
            30,
            child: ColoredBox(color: widget.color),
          ),
        ),
      ),
    );
  }
}
