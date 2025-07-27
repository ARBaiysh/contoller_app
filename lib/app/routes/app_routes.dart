part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const AUTH = _Paths.AUTH;
  static const HOME = _Paths.HOME;
  static const TP_LIST = _Paths.TP_LIST;
  static const SUBSCRIBERS = _Paths.SUBSCRIBERS;
  static const SUBSCRIBER_DETAIL = _Paths.SUBSCRIBER_DETAIL;
  static const SEARCH = _Paths.SEARCH;
  static const REPORTS = _Paths.REPORTS;
  static const REPORT_VIEWER = _Paths.REPORT_VIEWER;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();

  static const AUTH = '/auth';
  static const HOME = '/home';
  static const TP_LIST = '/tp-list';
  static const SUBSCRIBERS = '/subscribers';
  static const SUBSCRIBER_DETAIL = '/subscriber-detail';
  static const SEARCH = '/search';
  static const REPORTS = '/reports';
  static const REPORT_VIEWER = '/report-viewer';
  static const SETTINGS = '/settings';
}