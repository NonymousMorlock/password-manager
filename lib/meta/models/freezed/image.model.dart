// 📦 Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image.model.freezed.dart';
part 'image.model.g.dart';

@freezed
class Images with _$Images {
  factory Images({
    required String folderId,
    required String folderName,
    required int imageCount,
    required Set<String> images,
    required DateTime createdAt,
  }) = _Images;

  factory Images.fromJson(Map<String, dynamic> json) => _$ImagesFromJson(json);
}
