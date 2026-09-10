import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardService {
  Timer? _clearTimer;
  String? _lastCopiedCode;

  Future<void> copyCode(String code, {int clearAfterSeconds = 30}) async {
    final numeric = code.replaceAll(' ', '');
    await Clipboard.setData(ClipboardData(text: numeric));
    _lastCopiedCode = numeric;

    _clearTimer?.cancel();
    if (clearAfterSeconds <= 0) {
      return;
    }

    _clearTimer = Timer(Duration(seconds: clearAfterSeconds), () async {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      final currentText = current?.text?.replaceAll(' ', '');
      if (currentText != null &&
          _lastCopiedCode != null &&
          currentText == _lastCopiedCode) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
      _lastCopiedCode = null;
    });
  }

  void dispose() {
    _clearTimer?.cancel();
  }
}
