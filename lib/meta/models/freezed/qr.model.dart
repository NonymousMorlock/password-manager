// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr.model.freezed.dart';

@freezed
class QrModel with _$QrModel {
  const factory QrModel({
    required String atSign,
    required String cramSecret,
  }) = _QrModel;
}
