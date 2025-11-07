class RegionModel {
  final String code;
  final String name;

  RegionModel({
    required this.code,
    required this.name,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  static RegionModel empty() {
    return RegionModel(
      code: '',
      name: '',
    );
  }
}