part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const AUTH = _Paths.AUTH;
  static const HOME = _Paths.HOME;
  static const TP_LIST = _Paths.TP_LIST;
  static const SUBSCRIBERS = _Paths.SUBSCRIBERS;
  static const SUBSCRIBER_DETAIL = _Paths.SUBSCRIBER_DETAIL;
  static const SEARCH = _Paths.SEARCH;
  static const REPORTS = _Paths.REPORTS;
  static const REPORT_VIEWER = _Paths.REPORT_VIEWER;
  static const SETTINGS = _Paths.SETTINGS;
  static const NEWS = _Paths.NEWS;
  static const NEWS_DETAIL = _Paths.NEWS_DETAIL;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const NOTIFICATION_DETAIL = _Paths.NOTIFICATION_DETAIL;
  static const NAVBAR = _Paths.NAVBAR;
  static const HELP_SUPPORT = _Paths.HELP_SUPPORT;
  static const ABOUT = _Paths.ABOUT;
  static const UPDATE_REQUIRED = _Paths.UPDATE_REQUIRED;
  static const ABONENT_LIST = _Paths.ABONENT_LIST;
  static const METER_DETAIL = _Paths.METER_DETAIL;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const AUTH = '/auth';
  static const HOME = '/home';
  static const TP_LIST = '/tp-list';
  static const SUBSCRIBERS = '/subscribers';
  static const SUBSCRIBER_DETAIL = '/subscriber-detail';
  static const SEARCH = '/search';
  static const REPORTS = '/reports';
  static const REPORT_VIEWER = '/report-viewer';
  static const SETTINGS = '/settings';
  static const NEWS = '/news';
  static const NEWS_DETAIL = '/news/detail';
  static const NOTIFICATIONS = '/notifications';
  static const NOTIFICATION_DETAIL = '/notifications/detail';
  static const NAVBAR = '/';
  static const HELP_SUPPORT = '/help-support';
  static const ABOUT = '/about';
  static const UPDATE_REQUIRED = '/update-required';
  static const ABONENT_LIST = '/abonent-list';
  static const METER_DETAIL = '/meter-detail';
}