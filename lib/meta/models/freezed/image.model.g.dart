// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Images _$$_ImagesFromJson(Map<String, dynamic> json) => _$_Images(
      folderId: json['folderId'] as String,
      folderName: json['folderName'] as String,
      imageCount: json['imageCount'] as int,
      images: (json['images'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as String),
      ),
    );

Map<String, dynamic> _$$_ImagesToJson(_$_Images instance) => <String, dynamic>{
      'folderId': instance.folderId,
      'folderName': instance.folderName,
      'imageCount': instance.imageCount,
      'images': instance.images.map((k, e) => MapEntry(k.toString(), e)),
    };
