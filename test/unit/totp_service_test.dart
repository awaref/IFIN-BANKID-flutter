import 'dart:convert';

import 'package:bankid_app/features/authenticator/data/models/totp_account.dart';
import 'package:bankid_app/features/authenticator/data/services/totp_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otp_auth/otp_auth.dart';

void main() {
  final service = TotpService();

  DateTime epoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

  String secretForAlgorithm(TotpAlgorithm algorithm) {
    switch (algorithm) {
      case TotpAlgorithm.sha1:
        return Base32.encode(utf8.encode('12345678901234567890'));
      case TotpAlgorithm.sha256:
        return Base32.encode(utf8.encode('12345678901234567890123456789012'));
      case TotpAlgorithm.sha512:
        return Base32.encode(utf8.encode(
          '1234567890123456789012345678901234567890123456789012345678901234',
        ));
    }
  }

  TotpAccount account({
    TotpAlgorithm algorithm = TotpAlgorithm.sha1,
    int digits = 6,
    int period = 30,
  }) {
    return TotpAccount(
      id: 'test-id',
      issuer: 'Test',
      accountName: 'user@example.com',
      secret: secretForAlgorithm(algorithm),
      algorithm: algorithm,
      digits: digits,
      period: period,
    );
  }

  group('RFC 6238 SHA1 vectors (6-digit)', () {
    const vectors = <int, String>{
      59: '287082',
      1111111109: '081804',
      1111111111: '050471',
      1234567890: '005924',
      2000000000: '279037',
    };

    for (final entry in vectors.entries) {
      test('t=${entry.key}', () {
        final acc = account();
        expect(
          service.generateRawCode(acc, entry.key).toString().padLeft(6, '0'),
          entry.value,
        );
      });
    }
  });

  group('RFC 6238 SHA256 vectors (6-digit)', () {
    const vectors = <int, String>{
      59: '119246',
      1111111109: '084774',
      1111111111: '062674',
      1234567890: '819424',
      2000000000: '698825',
    };

    for (final entry in vectors.entries) {
      test('t=${entry.key}', () {
        final acc = account(algorithm: TotpAlgorithm.sha256);
        expect(
          service.generateRawCode(acc, entry.key).toString().padLeft(6, '0'),
          entry.value,
        );
      });
    }
  });

  group('RFC 6238 SHA512 vectors (6-digit)', () {
    const vectors = <int, String>{
      59: '693936',
      1111111109: '091201',
      1111111111: '943326',
      1234567890: '441116',
      2000000000: '618901',
    };

    for (final entry in vectors.entries) {
      test('t=${entry.key}', () {
        final acc = account(algorithm: TotpAlgorithm.sha512);
        expect(
          service.generateRawCode(acc, entry.key).toString().padLeft(6, '0'),
          entry.value,
        );
      });
    }
  });

  group('RFC 6238 appendix B (8-digit)', () {
    test('SHA1 at t=59', () {
      final acc = account(digits: 8);
      expect(
        service.generateRawCode(acc, 59).toString().padLeft(8, '0'),
        '94287082',
      );
    });

    test('SHA256 at t=20000000000', () {
      final acc = account(algorithm: TotpAlgorithm.sha256, digits: 8);
      expect(
        service.generateRawCode(acc, 20000000000).toString().padLeft(8, '0'),
        '77737706',
      );
    });

    test('SHA512 at t=20000000000', () {
      final acc = account(algorithm: TotpAlgorithm.sha512, digits: 8);
      expect(
        service.generateRawCode(acc, 20000000000).toString().padLeft(8, '0'),
        '47863826',
      );
    });
  });

  group('period handling', () {
    test('60-second period uses different counter than 30-second', () {
      const epochSeconds = 90;
      final acc30 = account(period: 30);
      final acc60 = account(period: 60);
      expect(
        service.generateRawCode(acc30, epochSeconds),
        isNot(service.generateRawCode(acc60, epochSeconds)),
      );
    });

    test('codes are stable within the same period window', () {
      final acc = account();
      expect(service.generateRawCode(acc, 30), service.generateRawCode(acc, 59));
      expect(service.generateRawCode(acc, 0), service.generateRawCode(acc, 29));
    });

    test('code changes at period boundary', () {
      final acc = account();
      expect(service.generateRawCode(acc, 29), isNot(service.generateRawCode(acc, 30)));
    });
  });

  group('cross-validation with otp_auth', () {
    test('matches otp_auth for JBSWY3DPEHPK3PXP secret', () {
      final acc = TotpAccount(
        id: 'id',
        issuer: 'Issuer',
        accountName: 'user',
        secret: 'JBSWY3DPEHPK3PXP',
      );
      final reference = TOTP(secret: 'JBSWY3DPEHPK3PXP');
      const epochSeconds = 1111111111;
      expect(
        service.generateRawCode(acc, epochSeconds).toString().padLeft(6, '0'),
        reference.at(epoch(epochSeconds)),
      );
    });
  });

  group('formatting', () {
    test('formats 6-digit code with space', () {
      expect(service.formatCode(287082, 6), '287 082');
    });

    test('formats 8-digit code with space', () {
      expect(service.formatCode(94287082, 8), '9428 7082');
    });
  });

  group('remaining seconds', () {
    test('returns seconds until next period', () {
      expect(service.remainingSeconds(30, 59), 1);
      expect(service.remainingSeconds(30, 60), 30);
      expect(service.remainingSeconds(60, 90), 30);
    });
  });

  group('Base32 secret normalization', () {
    test('accepts secrets with spaces and lowercase', () {
      final acc = TotpAccount(
        id: 'id',
        issuer: 'Issuer',
        accountName: 'user',
        secret: 'jbswy3dpehpk3pxp',
      );
      expect(service.generateRawCode(acc, 1111111111), isNonZero);
    });
  });

  group('elogic TestAuthenticator fixed secret', () {
    // Hex seed F7675FB111CF4B5EB2FAE36B5BDC7B61BF4199E3 from
    // KashifMushtaq/AuthenticatorTest Default.aspx.cs → Base32 below.
    // Independent HMAC-SHA1 reference at t=1111111111 → 848226.
    const secret = '65TV7MIRZ5FV5MX24NVVXXD3MG7UDGPD';
    const seedHex = 'F7675FB111CF4B5EB2FAE36B5BDC7B61BF4199E3';

    TotpAccount elogicAccount() => TotpAccount(
          id: 'elogic',
          issuer: 'elogic.synology.me',
          accountName: 'test@elogic.synology.me',
          secret: secret,
        );

    test('Base32 secret decodes to published hex seed', () {
      final bytes = Base32.decode(secret);
      final hex = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
      expect(hex, seedHex);
    });

    test('matches independent HMAC vector at t=1111111111', () {
      expect(
        service
            .generateRawCode(elogicAccount(), 1111111111)
            .toString()
            .padLeft(6, '0'),
        '848226',
      );
    });

    test('matches otp_auth for the same secret and timestamp', () {
      final reference = TOTP(secret: secret);
      expect(
        service
            .generateRawCode(elogicAccount(), 1111111111)
            .toString()
            .padLeft(6, '0'),
        reference.at(epoch(1111111111)),
      );
    });
  });
}
