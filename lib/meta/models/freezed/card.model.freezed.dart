// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'card.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CardModel _$CardModelFromJson(Map<String, dynamic> json) {
  return _CardModel.fromJson(json);
}

/// @nodoc
class _$CardModelTearOff {
  const _$CardModelTearOff();

  _CardModel call(
      {required String nameOnCard,
      required String cardNumber,
      required String expiryDate,
      required String cvv,
      required String cardType,
      String? id}) {
    return _CardModel(
      nameOnCard: nameOnCard,
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cvv: cvv,
      cardType: cardType,
      id: id,
    );
  }

  CardModel fromJson(Map<String, Object?> json) {
    return CardModel.fromJson(json);
  }
}

/// @nodoc
const $CardModel = _$CardModelTearOff();

/// @nodoc
mixin _$CardModel {
  String get nameOnCard => throw _privateConstructorUsedError;
  String get cardNumber => throw _privateConstructorUsedError;
  String get expiryDate => throw _privateConstructorUsedError;
  String get cvv => throw _privateConstructorUsedError;
  String get cardType => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CardModelCopyWith<CardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardModelCopyWith<$Res> {
  factory $CardModelCopyWith(CardModel value, $Res Function(CardModel) then) =
      _$CardModelCopyWithImpl<$Res>;
  $Res call(
      {String nameOnCard,
      String cardNumber,
      String expiryDate,
      String cvv,
      String cardType,
      String? id});
}

/// @nodoc
class _$CardModelCopyWithImpl<$Res> implements $CardModelCopyWith<$Res> {
  _$CardModelCopyWithImpl(this._value, this._then);

  final CardModel _value;
  // ignore: unused_field
  final $Res Function(CardModel) _then;

  @override
  $Res call({
    Object? nameOnCard = freezed,
    Object? cardNumber = freezed,
    Object? expiryDate = freezed,
    Object? cvv = freezed,
    Object? cardType = freezed,
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      nameOnCard: nameOnCard == freezed
          ? _value.nameOnCard
          : nameOnCard // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: cardNumber == freezed
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      expiryDate: expiryDate == freezed
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String,
      cvv: cvv == freezed
          ? _value.cvv
          : cvv // ignore: cast_nullable_to_non_nullable
              as String,
      cardType: cardType == freezed
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as String,
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$CardModelCopyWith<$Res> implements $CardModelCopyWith<$Res> {
  factory _$CardModelCopyWith(
          _CardModel value, $Res Function(_CardModel) then) =
      __$CardModelCopyWithImpl<$Res>;
  @override
  $Res call(
      {String nameOnCard,
      String cardNumber,
      String expiryDate,
      String cvv,
      String cardType,
      String? id});
}

/// @nodoc
class __$CardModelCopyWithImpl<$Res> extends _$CardModelCopyWithImpl<$Res>
    implements _$CardModelCopyWith<$Res> {
  __$CardModelCopyWithImpl(_CardModel _value, $Res Function(_CardModel) _then)
      : super(_value, (v) => _then(v as _CardModel));

  @override
  _CardModel get _value => super._value as _CardModel;

  @override
  $Res call({
    Object? nameOnCard = freezed,
    Object? cardNumber = freezed,
    Object? expiryDate = freezed,
    Object? cvv = freezed,
    Object? cardType = freezed,
    Object? id = freezed,
  }) {
    return _then(_CardModel(
      nameOnCard: nameOnCard == freezed
          ? _value.nameOnCard
          : nameOnCard // ignore: cast_nullable_to_non_nullable
              as String,
      cardNumber: cardNumber == freezed
          ? _value.cardNumber
          : cardNumber // ignore: cast_nullable_to_non_nullable
              as String,
      expiryDate: expiryDate == freezed
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as String,
      cvv: cvv == freezed
          ? _value.cvv
          : cvv // ignore: cast_nullable_to_non_nullable
              as String,
      cardType: cardType == freezed
          ? _value.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as String,
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CardModel implements _CardModel {
  _$_CardModel(
      {required this.nameOnCard,
      required this.cardNumber,
      required this.expiryDate,
      required this.cvv,
      required this.cardType,
      this.id});

  factory _$_CardModel.fromJson(Map<String, dynamic> json) =>
      _$$_CardModelFromJson(json);

  @override
  final String nameOnCard;
  @override
  final String cardNumber;
  @override
  final String expiryDate;
  @override
  final String cvv;
  @override
  final String cardType;
  @override
  final String? id;

  @override
  String toString() {
    return 'CardModel(nameOnCard: $nameOnCard, cardNumber: $cardNumber, expiryDate: $expiryDate, cvv: $cvv, cardType: $cardType, id: $id)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CardModel &&
            const DeepCollectionEquality()
                .equals(other.nameOnCard, nameOnCard) &&
            const DeepCollectionEquality()
                .equals(other.cardNumber, cardNumber) &&
            const DeepCollectionEquality()
                .equals(other.expiryDate, expiryDate) &&
            const DeepCollectionEquality().equals(other.cvv, cvv) &&
            const DeepCollectionEquality().equals(other.cardType, cardType) &&
            const DeepCollectionEquality().equals(other.id, id));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(nameOnCard),
      const DeepCollectionEquality().hash(cardNumber),
      const DeepCollectionEquality().hash(expiryDate),
      const DeepCollectionEquality().hash(cvv),
      const DeepCollectionEquality().hash(cardType),
      const DeepCollectionEquality().hash(id));

  @JsonKey(ignore: true)
  @override
  _$CardModelCopyWith<_CardModel> get copyWith =>
      __$CardModelCopyWithImpl<_CardModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CardModelToJson(this);
  }
}

abstract class _CardModel implements CardModel {
  factory _CardModel(
      {required String nameOnCard,
      required String cardNumber,
      required String expiryDate,
      required String cvv,
      required String cardType,
      String? id}) = _$_CardModel;

  factory _CardModel.fromJson(Map<String, dynamic> json) =
      _$_CardModel.fromJson;

  @override
  String get nameOnCard;
  @override
  String get cardNumber;
  @override
  String get expiryDate;
  @override
  String get cvv;
  @override
  String get cardType;
  @override
  String? get id;
  @override
  @JsonKey(ignore: true)
  _$CardModelCopyWith<_CardModel> get copyWith =>
      throw _privateConstructorUsedError;
}
