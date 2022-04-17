// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.model.freezed.dart';
part 'card.model.g.dart';

@freezed
class CardModel with _$CardModel {
  factory CardModel({
    required String nameOnCard,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardType,
    String? id,
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);
}
