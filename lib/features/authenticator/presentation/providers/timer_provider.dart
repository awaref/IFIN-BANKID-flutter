import 'dart:async';

import 'package:flutter/foundation.dart';

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  int _epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  int get epochSeconds => _epochSeconds;

  void start() {
    if (_timer != null) {
      return;
    }
    _epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _epochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      notifyListeners();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
