import 'package:flutter_test/flutter_test.dart';

import 'package:contoller_app/app/data/models/region_model.dart';
import 'package:contoller_app/app/data/models/auth_response_model.dart';
import 'package:contoller_app/app/data/models/dashboard_model.dart';
import 'package:contoller_app/app/data/models/tp_model.dart';
import 'package:contoller_app/app/data/models/app_version_model.dart';
import 'package:contoller_app/app/data/models/meter_detail_model.dart';
import 'package:contoller_app/app/data/models/subscriber_model.dart';

void main() {
  group('RegionModel', () {
    test('parses RegionDto shape', () {
      final m = RegionModel.fromJson({'code': 'oshres', 'name': 'ЭНЕРГОСБЫТ'});
      expect(m.code, 'oshres');
      expect(m.name, 'ЭНЕРГОСБЫТ');
    });
  });

  group('AuthResponseModel / InspectorData', () {
    test('parses login response with nested inspector + refreshToken', () {
      final m = AuthResponseModel.fromJson({
        'status': 'success',
        'token': 'jwt.token.here',
        'refreshToken': 'refresh-abc',
        'inspector': {
          'id': 42,
          'username': 'ivanov',
          'fullName': 'Иванов И.И.',
          'phone': '+996555000000', // лишнее поле бэкенда — игнорируется моделью
          'regionCode': 'oshres',
          'regionName': 'ЭНЕРГОСБЫТ',
          'externalId': 'EXT-1',
        },
      });
      expect(m.token, 'jwt.token.here');
      expect(m.refreshToken, 'refresh-abc');
      expect(m.inspector.id, 42);
      expect(m.inspector.inspectorId, 42);
      expect(m.inspector.fullName, 'Иванов И.И.');
      expect(m.inspector.regionName, 'ЭНЕРГОСБЫТ');
    });

    test('survives missing inspector (defaults to empty)', () {
      final m = AuthResponseModel.fromJson({'token': 't'});
      expect(m.token, 't');
      expect(m.refreshToken, isNull);
      expect(m.inspector.id, 0);
    });
  });

  group('DashboardModel', () {
    test('parses DashboardStatsResponse', () {
      final m = DashboardModel.fromJson({
        'totalAbonents': 100,
        'totalTransformerPoints': 5,
        'readingsThisMonth': 40,
        'totalCharge': 1234.5,
        'totalDebt': 999,
        'totalPrepayment': 10,
        'totalConsumption': 5000,
        'paymentCountThisMonth': 30,
        'totalPaymentAmount': 7777.7,
        'coordinatesTotal': 80,
        'coordinatesThisMonth': 12,
        'coordinatesToday': 3,
      });
      expect(m.totalAbonents, 100);
      expect(m.totalDebt, 999.0); // int → double
      expect(m.readingsRemaining, 60);
      expect(m.completionPercentage, closeTo(40.0, 0.001));
    });

    test('missing fields do not crash', () {
      final m = DashboardModel.fromJson({});
      expect(m.totalAbonents, 0);
      expect(m.totalDebt, 0.0);
    });
  });

  group('TpModel', () {
    test('maps totalAbonents→abonentCount, snake reading fields, default active', () {
      final m = TpModel.fromJson({
        'code': 'TP-001',
        'name': 'ТП-1',
        'number': '001',
        'fider': 'F1',
        'totalAbonents': 25,
        'lastSync': '2026-06-16T10:00:00',
        'total_subscribers': 25,
        'readings_collected': 10,
        'readings_available': 15,
      });
      expect(m.code, 'TP-001');
      expect(m.abonentCount, 25);
      expect(m.totalSubscribers, 25);
      expect(m.readingsCollected, 10);
      expect(m.readingsAvailable, 15);
      expect(m.active, isTrue); // бэкенд не присылает — дефолт true
      expect(m.lastSync?.year, 2026);
      expect(m.progressPercentage, closeTo(40.0, 0.001));
    });
  });

  group('AppVersionModel', () {
    test('parses AppVersionDto', () {
      final m = AppVersionModel.fromJson({
        'currentVersion': '1.0.14',
        'currentBuildNumber': 14,
        'minVersion': '1.0.10',
        'minBuildNumber': 10,
        'forceUpdate': true,
        'updateMessage': 'Обновитесь',
        'apkUrl': 'https://x/y.apk',
        'apkSize': 1048576,
        'releaseNotes': 'fixes',
      });
      expect(m.currentBuildNumber, 14);
      expect(m.needsUpdate(9), isTrue);
      expect(m.needsUpdate(10), isFalse);
      expect(m.hasNewerVersion(13), isTrue);
      expect(m.formattedSize, '1.0 МБ');
    });
  });

  group('MeterDetailModel', () {
    test('parses snake_case MeterDataDto', () {
      final m = MeterDetailModel.fromJson({
        'meter_type': 'СО-505',
        'meter_number': 'M-123',
        'meter_date': '2025-01-15T00:00:00',
        'coefficient': 1,
        'phase': 3,
        'amperage': '5-60',
        'digit_capacity': 6,
        'state_seal': 'СП-1',
        'one_time_seal': '-',
        'cover_seal': '',
        'box_seal': 'BX',
      });
      expect(m.meterType, 'СО-505');
      expect(m.meterNumber, 'M-123');
      expect(m.phase, 3);
      expect(m.digitCapacity, 6);
      expect(m.phaseDescription, 'Трёхфазный');
      expect(m.meterDate?.year, 2025);
      expect(m.isSealValid(m.oneTimeSeal), isFalse); // '-' невалиден
      expect(m.isSealValid(m.boxSeal), isTrue);
    });
  });

  group('SubscriberModel (AbonentDto)', () {
    test('maps lastReading→currentReading, int consumption→double, dates', () {
      final m = SubscriberModel.fromJson({
        'accountNumber': '12345678901',
        'fullName': 'Петров П.П.',
        'address': 'ул. Ленина 1',
        'phone': '0555123456',
        'transformerPointCode': 'TP-001',
        'meterType': 'СО',
        'meterSerialNumber': 'SN-9',
        'tariffName': 'Бытовой',
        'balance': 250, // int в JSON → double
        'lastPaymentAmount': 100.0,
        'lastPaymentDate': '2026-05-20T00:00:00',
        'lastReading': 1500,
        'lastReadingDate': '2026-06-10T08:00:00',
        'currentMonthConsumption': 42, // Integer на бэкенде
        'currentMonthCharge': 130.5,
        'canTakeReading': false, // бэкендовое поле игнорируется (геттер вычисляет сам)
        'latitude': 40.5,
        'longitude': 72.8,
        'accuracy': 5.0,
      });
      expect(m.accountNumber, '12345678901');
      expect(m.currentReading, 1500);
      expect(m.lastReading, 1500);
      expect(m.balance, 250.0);
      expect(m.isDebtor, isTrue);
      expect(m.currentMonthConsumption, 42.0);
      expect(m.lastReadingDate?.month, 6);
      expect(m.hasCoordinates, isTrue);
      expect(m.phone, '0555123456');
      expect(m.hasValidPhone, isTrue);
    });

    test('phone placeholder becomes null', () {
      final m = SubscriberModel.fromJson({
        'accountNumber': '1',
        'fullName': 'X',
        'address': 'Y',
        'meterSerialNumber': 'S',
        'transformerPointCode': 'TP',
        'phone': 'неопределено',
      });
      expect(m.phone, isNull);
      expect(m.hasValidPhone, isFalse);
    });

    test('missing optional fields default safely', () {
      final m = SubscriberModel.fromJson({
        'accountNumber': '1',
        'fullName': 'X',
        'address': 'Y',
        'meterSerialNumber': 'S',
        'transformerPointCode': 'TP',
      });
      expect(m.balance, 0.0);
      expect(m.currentReading, 0);
      expect(m.previousReading, 0);
      expect(m.tariff, 0.0);
      expect(m.transformerPointName, '');
      expect(m.lastReadingDate, isNull);
      expect(m.canTakeReading, isTrue); // нет даты → можно снимать
    });

    test('round-trips through toJson/fromJson', () {
      final original = SubscriberModel.fromJson({
        'accountNumber': '777',
        'fullName': 'Round Trip',
        'address': 'A',
        'meterSerialNumber': 'S',
        'transformerPointCode': 'TP',
        'lastReading': 99,
        'balance': 12.5,
      });
      final copy = SubscriberModel.fromJson(original.toJson());
      expect(copy.accountNumber, '777');
      expect(copy.currentReading, 99); // toJson пишет 'lastReading', fromJson читает обратно
      expect(copy.balance, 12.5);
    });
  });
}
