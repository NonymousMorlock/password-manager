// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'password.model.freezed.dart';

part 'password.model.g.dart';

@freezed
class Password with _$Password {
  const factory Password({
    required String favicon,
    required String? name,
    required String? password,
  }) = _Password;

  factory Password.fromJson(Map<String, dynamic> json) =>
      _$PasswordFromJson(json);
}
