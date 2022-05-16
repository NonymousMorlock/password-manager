// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Images _$$_ImagesFromJson(Map<String, dynamic> json) => _$_Images(
      folderId: json['folderId'] as String,
      folderName: json['folderName'] as String,
      imageCount: json['imageCount'] as int,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toSet(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$_ImagesToJson(_$_Images instance) => <String, dynamic>{
      'folderId': instance.folderId,
      'folderName': instance.folderName,
      'imageCount': instance.imageCount,
      'images': instance.images.toList(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
