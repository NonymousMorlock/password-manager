// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'qr.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$QrModelTearOff {
  const _$QrModelTearOff();

  _QrModel call({required String atSign, required String cramSecret}) {
    return _QrModel(
      atSign: atSign,
      cramSecret: cramSecret,
    );
  }
}

/// @nodoc
const $QrModel = _$QrModelTearOff();

/// @nodoc
mixin _$QrModel {
  String get atSign => throw _privateConstructorUsedError;
  String get cramSecret => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QrModelCopyWith<QrModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrModelCopyWith<$Res> {
  factory $QrModelCopyWith(QrModel value, $Res Function(QrModel) then) =
      _$QrModelCopyWithImpl<$Res>;
  $Res call({String atSign, String cramSecret});
}

/// @nodoc
class _$QrModelCopyWithImpl<$Res> implements $QrModelCopyWith<$Res> {
  _$QrModelCopyWithImpl(this._value, this._then);

  final QrModel _value;
  // ignore: unused_field
  final $Res Function(QrModel) _then;

  @override
  $Res call({
    Object? atSign = freezed,
    Object? cramSecret = freezed,
  }) {
    return _then(_value.copyWith(
      atSign: atSign == freezed
          ? _value.atSign
          : atSign // ignore: cast_nullable_to_non_nullable
              as String,
      cramSecret: cramSecret == freezed
          ? _value.cramSecret
          : cramSecret // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$QrModelCopyWith<$Res> implements $QrModelCopyWith<$Res> {
  factory _$QrModelCopyWith(_QrModel value, $Res Function(_QrModel) then) =
      __$QrModelCopyWithImpl<$Res>;
  @override
  $Res call({String atSign, String cramSecret});
}

/// @nodoc
class __$QrModelCopyWithImpl<$Res> extends _$QrModelCopyWithImpl<$Res>
    implements _$QrModelCopyWith<$Res> {
  __$QrModelCopyWithImpl(_QrModel _value, $Res Function(_QrModel) _then)
      : super(_value, (v) => _then(v as _QrModel));

  @override
  _QrModel get _value => super._value as _QrModel;

  @override
  $Res call({
    Object? atSign = freezed,
    Object? cramSecret = freezed,
  }) {
    return _then(_QrModel(
      atSign: atSign == freezed
          ? _value.atSign
          : atSign // ignore: cast_nullable_to_non_nullable
              as String,
      cramSecret: cramSecret == freezed
          ? _value.cramSecret
          : cramSecret // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_QrModel implements _QrModel {
  const _$_QrModel({required this.atSign, required this.cramSecret});

  @override
  final String atSign;
  @override
  final String cramSecret;

  @override
  String toString() {
    return 'QrModel(atSign: $atSign, cramSecret: $cramSecret)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _QrModel &&
            const DeepCollectionEquality().equals(other.atSign, atSign) &&
            const DeepCollectionEquality()
                .equals(other.cramSecret, cramSecret));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(atSign),
      const DeepCollectionEquality().hash(cramSecret));

  @JsonKey(ignore: true)
  @override
  _$QrModelCopyWith<_QrModel> get copyWith =>
      __$QrModelCopyWithImpl<_QrModel>(this, _$identity);
}

abstract class _QrModel implements QrModel {
  const factory _QrModel({required String atSign, required String cramSecret}) =
      _$_QrModel;

  @override
  String get atSign;
  @override
  String get cramSecret;
  @override
  @JsonKey(ignore: true)
  _$QrModelCopyWith<_QrModel> get copyWith =>
      throw _privateConstructorUsedError;
}
