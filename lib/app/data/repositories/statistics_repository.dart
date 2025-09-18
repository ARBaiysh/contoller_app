import 'package:get/get.dart';
import '../models/statistics_model.dart';
import '../models/tp_model.dart';
import '../models/subscriber_model.dart';
import '../providers/api_provider.dart';
import 'tp_repository.dart';
import 'subscriber_repository.dart';

class StatisticsRepository {
  // Временно возвращаем пустую статистику
  // TODO: Реализовать после добавления соответствующего endpoint в API
  Future<StatisticsModel> getStatistics() async {
    // Временные данные для работы приложения
    return StatisticsModel(
      totalSubscribers: 0,
      readingsCollected: 0,
      readingsRemaining: 0,
      paidSubscribers: 0,
      debtorCount: 0,
      totalDebtAmount: 0.0,
      totalCollectedAmount: 0.0,
      lastUpdated: DateTime.now(),
    );
  }
}