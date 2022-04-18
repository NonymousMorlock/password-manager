// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Report _$$_ReportFromJson(Map<String, dynamic> json) => _$_Report(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      from: json['from'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      image: json['image'] as String,
    );

Map<String, dynamic> _$$_ReportToJson(_$_Report instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'from': instance.from,
      'createdAt': instance.createdAt.toIso8601String(),
      'image': instance.image,
    };
