class TpListResponseModel {
  final List<dynamic> data;
  final bool syncing;
  final int? syncMessageId;
  final String? message;

  TpListResponseModel({
    required this.data,
    required this.syncing,
    this.syncMessageId,
    this.message,
  });

  factory TpListResponseModel.fromJson(Map<String, dynamic> json) {
    return TpListResponseModel(
      data: json['data'] ?? [],
      syncing: json['syncing'] ?? false,
      syncMessageId: json['syncMessageId'],
      message: json['message'],
    );
  }
}