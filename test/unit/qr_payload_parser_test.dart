import 'package:bankid_app/services/qr_payload_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrPayloadParser', () {
    const valid =
        'bankid.67df3917-fa0d-44e5-b327-edcc928297f8.12.a9e5ec59a9e5ec59a9e5ec59a9e5ec59a9e5ec59a9e5ec59a9e5ec59a9e5ec59';

    test('accepts valid animated payload', () {
      expect(QrPayloadParser.isValidAnimatedPayload(valid), isTrue);
      expect(QrPayloadParser.looksLikeLegacyToken(valid), isFalse);
      expect(QrPayloadParser.normalize('  $valid  '), valid);
    });

    test('rejects old raw token without dots', () {
      const raw = 'AbCdEfGhIjKlMnOpQrStUvWxYz012345';
      expect(QrPayloadParser.isValidAnimatedPayload(raw), isFalse);
      expect(QrPayloadParser.looksLikeLegacyToken(raw), isTrue);
    });

    test('rejects wrong segment count', () {
      const three = 'bankid.67df3917-fa0d-44e5-b327-edcc928297f8.12';
      expect(QrPayloadParser.isValidAnimatedPayload(three), isFalse);
      expect(QrPayloadParser.looksLikeLegacyToken(three), isTrue);
    });

    test('rejects invalid hmac length', () {
      const shortHmac =
          'bankid.67df3917-fa0d-44e5-b327-edcc928297f8.12.abcd';
      expect(QrPayloadParser.isValidAnimatedPayload(shortHmac), isFalse);
    });

    test('rejects empty string', () {
      expect(QrPayloadParser.isValidAnimatedPayload(''), isFalse);
      expect(QrPayloadParser.looksLikeLegacyToken(''), isTrue);
    });

    test('accepts uppercase hex in uuid/hmac (case insensitive)', () {
      const upper =
          'BANKID.67DF3917-FA0D-44E5-B327-EDCC928297F8.12.A9E5EC59A9E5EC59A9E5EC59A9E5EC59A9E5EC59A9E5EC59A9E5EC59A9E5EC59';
      expect(QrPayloadParser.isValidAnimatedPayload(upper), isTrue);
    });
  });
}
