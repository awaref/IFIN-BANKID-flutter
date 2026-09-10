import 'package:bankid_app/features/authenticator/data/models/totp_account.dart';
import 'package:bankid_app/features/authenticator/data/services/otp_uri_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = OtpUriParser();

  group('valid URIs', () {
    test('parses standard Google Authenticator URI', () {
      const uri =
          'otpauth://totp/Issuer:user%40example.com?secret=JBSWY3DPEHPK3PXP&issuer=Issuer&algorithm=SHA1&digits=6&period=30';
      final account = parser.parse(uri);
      expect(account.issuer, 'Issuer');
      expect(account.accountName, 'user@example.com');
      expect(account.secret, 'JBSWY3DPEHPK3PXP');
      expect(account.algorithm, TotpAlgorithm.sha1);
      expect(account.digits, 6);
      expect(account.period, 30);
    });

    test('parses SHA256 and 8 digits', () {
      const uri =
          'otpauth://totp/Example:alice?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=8&period=60';
      final account = parser.parse(uri);
      expect(account.algorithm, TotpAlgorithm.sha256);
      expect(account.digits, 8);
      expect(account.period, 60);
    });

    test('parses SHA512', () {
      const uri =
          'otpauth://totp/Test?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512';
      final account = parser.parse(uri);
      expect(account.algorithm, TotpAlgorithm.sha512);
    });

    test('uses issuer parameter when label has no issuer prefix', () {
      const uri =
          'otpauth://totp/alice?secret=JBSWY3DPEHPK3PXP&issuer=MyBank';
      final account = parser.parse(uri);
      expect(account.issuer, 'MyBank');
      expect(account.accountName, 'alice');
    });

    test('parses elogic TestAuthenticator fixed-seed URI', () {
      const uri =
          'otpauth://totp/elogic.synology.me:test%40elogic.synology.me?secret=65TV7MIRZ5FV5MX24NVVXXD3MG7UDGPD&issuer=elogic.synology.me&algorithm=SHA1&digits=6&period=30';
      final account = parser.parse(uri);
      expect(account.issuer, 'elogic.synology.me');
      expect(account.accountName, 'test@elogic.synology.me');
      expect(account.secret, '65TV7MIRZ5FV5MX24NVVXXD3MG7UDGPD');
      expect(account.algorithm, TotpAlgorithm.sha1);
      expect(account.digits, 6);
      expect(account.period, 30);
    });
  });

  group('invalid URIs', () {
    test('rejects non-otpauth strings', () {
      expect(
        () => parser.parse('https://example.com'),
        throwsA(isA<OtpUriParseException>()),
      );
    });

    test('rejects HOTP URIs', () {
      expect(
        () => parser.parse('otpauth://hotp/Test?secret=JBSWY3DPEHPK3PXP'),
        throwsA(isA<OtpUriParseException>()),
      );
    });

    test('rejects missing secret', () {
      expect(
        () => parser.parse('otpauth://totp/Test?issuer=Example'),
        throwsA(isA<OtpUriParseException>()),
      );
    });

    test('rejects invalid digits', () {
      expect(
        () => parser.parse(
          'otpauth://totp/Test?secret=JBSWY3DPEHPK3PXP&digits=7',
        ),
        throwsA(isA<OtpUriParseException>()),
      );
    });

    test('rejects invalid period', () {
      expect(
        () => parser.parse(
          'otpauth://totp/Test?secret=JBSWY3DPEHPK3PXP&period=0',
        ),
        throwsA(isA<OtpUriParseException>()),
      );
    });

    test('rejects invalid Base32 secret', () {
      expect(
        () => parser.parse('otpauth://totp/Test?secret=!!!invalid!!!'),
        throwsA(isA<OtpUriParseException>()),
      );
    });
  });
}
