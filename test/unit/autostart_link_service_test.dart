import 'package:bankid_app/services/autostart_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutostartLinkService.extractAutostartToken', () {
    test('parses ifinbankid:///?autostarttoken=', () {
      final uri = Uri.parse(
        'ifinbankid:///?autostarttoken=67df3917-fa0d-44e5-b327-edcc928297f8',
      );
      expect(
        AutostartLinkService.extractAutostartToken(uri),
        '67df3917-fa0d-44e5-b327-edcc928297f8',
      );
    });

    test('parses ifinbankid://autostart?token=', () {
      final uri = Uri.parse(
        'ifinbankid://autostart?token=67df3917-fa0d-44e5-b327-edcc928297f8',
      );
      expect(
        AutostartLinkService.extractAutostartToken(uri),
        '67df3917-fa0d-44e5-b327-edcc928297f8',
      );
    });

    test('returns null for wrong scheme', () {
      final uri = Uri.parse('https://example.com/?autostarttoken=abc');
      expect(AutostartLinkService.extractAutostartToken(uri), isNull);
    });

    test('returns null when token missing', () {
      final uri = Uri.parse('ifinbankid:///');
      expect(AutostartLinkService.extractAutostartToken(uri), isNull);
    });
  });
}
