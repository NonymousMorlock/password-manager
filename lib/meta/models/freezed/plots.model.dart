// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plots.model.freezed.dart';

@freezed
class Plots with _$Plots {
  const factory Plots({
    required double x,
    required double y,
  }) = _Plots;
}
