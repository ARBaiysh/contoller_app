import 'package:json_annotation/json_annotation.dart';

part 'region_model.g.dart';

@JsonSerializable()
class RegionModel {
  @JsonKey(defaultValue: '')
  final String code;
  @JsonKey(defaultValue: '')
  final String name;

  RegionModel({
    required this.code,
    required this.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegionModelToJson(this);

  static RegionModel empty() {
    return RegionModel(
      code: '',
      name: '',
    );
  }
}
