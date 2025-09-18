import 'subscriber_model.dart';

class AbonentsResponseModel {
  final List<SubscriberModel> data;
  final bool syncing;
  final int? syncMessageId;
  final String? message;

  AbonentsResponseModel({
    required this.data,
    required this.syncing,
    this.syncMessageId,
    this.message,
  });

  factory AbonentsResponseModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> jsonData = json['data'] ?? [];
    return AbonentsResponseModel(
      data: jsonData.map((item) => SubscriberModel.fromJson(item)).toList(),
      syncing: json['syncing'] ?? false,
      syncMessageId: json['syncMessageId'],
      message: json['message'],
    );
  }
}