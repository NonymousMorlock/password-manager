import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.model.freezed.dart';
part 'report.model.g.dart';

@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required String title,
    required String content,
    required String from,
    required DateTime createdAt,
    required String image,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
