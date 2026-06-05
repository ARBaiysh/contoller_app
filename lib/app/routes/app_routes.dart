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
  static const SETTINGS = _Paths.SETTINGS;
  static const NAVBAR = _Paths.NAVBAR;
  static const ABOUT = _Paths.ABOUT;
  static const UPDATE_REQUIRED = _Paths.UPDATE_REQUIRED;
  static const ABONENT_LIST = _Paths.ABONENT_LIST;
  static const METER_DETAIL = _Paths.METER_DETAIL;
  static const ASKUE_HISTORY = _Paths.ASKUE_HISTORY;
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
  static const SETTINGS = '/settings';
  static const NAVBAR = '/';
  static const ABOUT = '/about';
  static const UPDATE_REQUIRED = '/update-required';
  static const ABONENT_LIST = '/abonent-list';
  static const METER_DETAIL = '/meter-detail';
  static const ASKUE_HISTORY = '/askue-history';
}