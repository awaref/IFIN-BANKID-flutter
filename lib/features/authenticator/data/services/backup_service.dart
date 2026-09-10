import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../models/totp_account.dart';

class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BackupService {
  static const int _version = 1;
  static const String _format = 'bankid-totp-backup';
  static const int _iterations = 200000;

  String exportAccounts(List<TotpAccount> accounts, String password) {
    if (password.isEmpty) {
      throw BackupException('Backup password is required');
    }

    final payload = jsonEncode({
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'accounts': accounts.map((a) => a.toJson()).toList(),
    });

    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final key = _deriveKey(password, salt);
    final encrypted = _encryptAesGcm(
      Uint8List.fromList(utf8.encode(payload)),
      key,
      nonce,
    );

    return jsonEncode({
      'version': _version,
      'format': _format,
      'kdf': {
        'algorithm': 'PBKDF2-HMAC-SHA256',
        'iterations': _iterations,
        'keyBits': 256,
      },
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'ciphertext': base64Encode(encrypted.cipherText),
      'tag': base64Encode(encrypted.mac),
    });
  }

  List<TotpAccount> importAccounts(String encryptedJson, String password) {
    if (password.isEmpty) {
      throw BackupException('Backup password is required');
    }

    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(encryptedJson) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('Invalid backup format');
    }

    if (envelope['format'] != _format || envelope['version'] != _version) {
      throw BackupException('Invalid backup format');
    }

    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final cipherText = base64Decode(envelope['ciphertext'] as String);
    final tag = base64Decode(envelope['tag'] as String);
    final key = _deriveKey(password, salt);

    late final String plaintext;
    try {
      plaintext = utf8.decode(
        _decryptAesGcm(cipherText, key, nonce, tag),
      );
    } catch (_) {
      throw BackupException('Incorrect backup password or corrupted backup');
    }

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(plaintext) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('Invalid backup format');
    }

    final accountsJson = payload['accounts'];
    if (accountsJson is! List) {
      throw BackupException('Invalid backup format');
    }

    return accountsJson
        .map((item) => TotpAccount.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Uint8List _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _iterations, 32));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  _AesGcmResult _encryptAesGcm(Uint8List plainText, Uint8List key, Uint8List nonce) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)),
      );
    final output = cipher.process(plainText);
    final macLength = cipher.macSize;
    return _AesGcmResult(
      cipherText: output.sublist(0, output.length - macLength),
      mac: output.sublist(output.length - macLength),
    );
  }

  Uint8List _decryptAesGcm(
    Uint8List cipherText,
    Uint8List key,
    Uint8List nonce,
    Uint8List tag,
  ) {
    final combined = Uint8List(cipherText.length + tag.length)
      ..setRange(0, cipherText.length, cipherText)
      ..setRange(cipherText.length, cipherText.length + tag.length, tag);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0)),
      );
    return cipher.process(combined);
  }

  Uint8List _randomBytes(int length) {
    final random = FortunaRandom();
    random.seed(KeyParameter(_seedSecureRandom()));
    return random.nextBytes(length);
  }

  Uint8List _seedSecureRandom() {
    final secureRandom = FortunaRandom();
    final seed = Uint8List(32);
    final random = Random.secure();
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    secureRandom.seed(KeyParameter(seed));
    return secureRandom.nextBytes(32);
  }
}

class _AesGcmResult {
  _AesGcmResult({required this.cipherText, required this.mac});
  final Uint8List cipherText;
  final Uint8List mac;
}
