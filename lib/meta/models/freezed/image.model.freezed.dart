// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'image.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Images _$ImagesFromJson(Map<String, dynamic> json) {
  return _Images.fromJson(json);
}

/// @nodoc
class _$ImagesTearOff {
  const _$ImagesTearOff();

  _Images call(
      {required String folderId,
      required String folderName,
      required int imageCount,
      required Map<int, String> images}) {
    return _Images(
      folderId: folderId,
      folderName: folderName,
      imageCount: imageCount,
      images: images,
    );
  }

  Images fromJson(Map<String, Object?> json) {
    return Images.fromJson(json);
  }
}

/// @nodoc
const $Images = _$ImagesTearOff();

/// @nodoc
mixin _$Images {
  String get folderId => throw _privateConstructorUsedError;
  String get folderName => throw _privateConstructorUsedError;
  int get imageCount => throw _privateConstructorUsedError;
  Map<int, String> get images => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ImagesCopyWith<Images> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImagesCopyWith<$Res> {
  factory $ImagesCopyWith(Images value, $Res Function(Images) then) =
      _$ImagesCopyWithImpl<$Res>;
  $Res call(
      {String folderId,
      String folderName,
      int imageCount,
      Map<int, String> images});
}

/// @nodoc
class _$ImagesCopyWithImpl<$Res> implements $ImagesCopyWith<$Res> {
  _$ImagesCopyWithImpl(this._value, this._then);

  final Images _value;
  // ignore: unused_field
  final $Res Function(Images) _then;

  @override
  $Res call({
    Object? folderId = freezed,
    Object? folderName = freezed,
    Object? imageCount = freezed,
    Object? images = freezed,
  }) {
    return _then(_value.copyWith(
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      folderName: folderName == freezed
          ? _value.folderName
          : folderName // ignore: cast_nullable_to_non_nullable
              as String,
      imageCount: imageCount == freezed
          ? _value.imageCount
          : imageCount // ignore: cast_nullable_to_non_nullable
              as int,
      images: images == freezed
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as Map<int, String>,
    ));
  }
}

/// @nodoc
abstract class _$ImagesCopyWith<$Res> implements $ImagesCopyWith<$Res> {
  factory _$ImagesCopyWith(_Images value, $Res Function(_Images) then) =
      __$ImagesCopyWithImpl<$Res>;
  @override
  $Res call(
      {String folderId,
      String folderName,
      int imageCount,
      Map<int, String> images});
}

/// @nodoc
class __$ImagesCopyWithImpl<$Res> extends _$ImagesCopyWithImpl<$Res>
    implements _$ImagesCopyWith<$Res> {
  __$ImagesCopyWithImpl(_Images _value, $Res Function(_Images) _then)
      : super(_value, (v) => _then(v as _Images));

  @override
  _Images get _value => super._value as _Images;

  @override
  $Res call({
    Object? folderId = freezed,
    Object? folderName = freezed,
    Object? imageCount = freezed,
    Object? images = freezed,
  }) {
    return _then(_Images(
      folderId: folderId == freezed
          ? _value.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      folderName: folderName == freezed
          ? _value.folderName
          : folderName // ignore: cast_nullable_to_non_nullable
              as String,
      imageCount: imageCount == freezed
          ? _value.imageCount
          : imageCount // ignore: cast_nullable_to_non_nullable
              as int,
      images: images == freezed
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as Map<int, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Images implements _Images {
  _$_Images(
      {required this.folderId,
      required this.folderName,
      required this.imageCount,
      required this.images});

  factory _$_Images.fromJson(Map<String, dynamic> json) =>
      _$$_ImagesFromJson(json);

  @override
  final String folderId;
  @override
  final String folderName;
  @override
  final int imageCount;
  @override
  final Map<int, String> images;

  @override
  String toString() {
    return 'Images(folderId: $folderId, folderName: $folderName, imageCount: $imageCount, images: $images)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Images &&
            const DeepCollectionEquality().equals(other.folderId, folderId) &&
            const DeepCollectionEquality()
                .equals(other.folderName, folderName) &&
            const DeepCollectionEquality()
                .equals(other.imageCount, imageCount) &&
            const DeepCollectionEquality().equals(other.images, images));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(folderId),
      const DeepCollectionEquality().hash(folderName),
      const DeepCollectionEquality().hash(imageCount),
      const DeepCollectionEquality().hash(images));

  @JsonKey(ignore: true)
  @override
  _$ImagesCopyWith<_Images> get copyWith =>
      __$ImagesCopyWithImpl<_Images>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ImagesToJson(this);
  }
}

abstract class _Images implements Images {
  factory _Images(
      {required String folderId,
      required String folderName,
      required int imageCount,
      required Map<int, String> images}) = _$_Images;

  factory _Images.fromJson(Map<String, dynamic> json) = _$_Images.fromJson;

  @override
  String get folderId;
  @override
  String get folderName;
  @override
  int get imageCount;
  @override
  Map<int, String> get images;
  @override
  @JsonKey(ignore: true)
  _$ImagesCopyWith<_Images> get copyWith => throw _privateConstructorUsedError;
}
