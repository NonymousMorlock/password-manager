// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'plots.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$PlotsTearOff {
  const _$PlotsTearOff();

  _Plots call({required double x, required double y}) {
    return _Plots(
      x: x,
      y: y,
    );
  }
}

/// @nodoc
const $Plots = _$PlotsTearOff();

/// @nodoc
mixin _$Plots {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PlotsCopyWith<Plots> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlotsCopyWith<$Res> {
  factory $PlotsCopyWith(Plots value, $Res Function(Plots) then) =
      _$PlotsCopyWithImpl<$Res>;
  $Res call({double x, double y});
}

/// @nodoc
class _$PlotsCopyWithImpl<$Res> implements $PlotsCopyWith<$Res> {
  _$PlotsCopyWithImpl(this._value, this._then);

  final Plots _value;
  // ignore: unused_field
  final $Res Function(Plots) _then;

  @override
  $Res call({
    Object? x = freezed,
    Object? y = freezed,
  }) {
    return _then(_value.copyWith(
      x: x == freezed
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: y == freezed
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
abstract class _$PlotsCopyWith<$Res> implements $PlotsCopyWith<$Res> {
  factory _$PlotsCopyWith(_Plots value, $Res Function(_Plots) then) =
      __$PlotsCopyWithImpl<$Res>;
  @override
  $Res call({double x, double y});
}

/// @nodoc
class __$PlotsCopyWithImpl<$Res> extends _$PlotsCopyWithImpl<$Res>
    implements _$PlotsCopyWith<$Res> {
  __$PlotsCopyWithImpl(_Plots _value, $Res Function(_Plots) _then)
      : super(_value, (v) => _then(v as _Plots));

  @override
  _Plots get _value => super._value as _Plots;

  @override
  $Res call({
    Object? x = freezed,
    Object? y = freezed,
  }) {
    return _then(_Plots(
      x: x == freezed
          ? _value.x
          : x // ignore: cast_nullable_to_non_nullable
              as double,
      y: y == freezed
          ? _value.y
          : y // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$_Plots implements _Plots {
  const _$_Plots({required this.x, required this.y});

  @override
  final double x;
  @override
  final double y;

  @override
  String toString() {
    return 'Plots(x: $x, y: $y)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Plots &&
            const DeepCollectionEquality().equals(other.x, x) &&
            const DeepCollectionEquality().equals(other.y, y));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(x),
      const DeepCollectionEquality().hash(y));

  @JsonKey(ignore: true)
  @override
  _$PlotsCopyWith<_Plots> get copyWith =>
      __$PlotsCopyWithImpl<_Plots>(this, _$identity);
}

abstract class _Plots implements Plots {
  const factory _Plots({required double x, required double y}) = _$_Plots;

  @override
  double get x;
  @override
  double get y;
  @override
  @JsonKey(ignore: true)
  _$PlotsCopyWith<_Plots> get copyWith => throw _privateConstructorUsedError;
}
