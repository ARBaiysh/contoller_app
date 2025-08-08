import 'package:get/get.dart';

/// Controls main bottom navigation state without pushing new routes.
class MainNavController extends GetxController {
  /// Current tab index
  final RxInt currentIndex = 0.obs;

  /// Switch tab (no Navigator push)
  void switchTo(int index) {
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }

  /// Handle Android back: go to first tab if not there
  /// Return true if app should exit, false if we handled back
  bool handleBack() {
    if (currentIndex.value != 0) {
      currentIndex.value = 0;
      return false;
    }
    return true;
  }
}
