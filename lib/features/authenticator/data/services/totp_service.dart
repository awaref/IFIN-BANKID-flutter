import 'package:otp_auth/otp_auth.dart';

import '../models/totp_account.dart';

class TotpService {
  int generateRawCode(TotpAccount account, int epochSeconds) {
    final totp = _buildTotp(account);
    final code = totp.at(
      DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000, isUtc: true),
    );
    return int.parse(code);
  }

  String generateCode(TotpAccount account, int epochSeconds) {
    final code = generateRawCode(account, epochSeconds);
    return formatCode(code, account.digits);
  }

  int remainingSeconds(int period, int epochSeconds) {
    final elapsed = epochSeconds % period;
    return period - elapsed;
  }

  double progress(int period, int epochSeconds) {
    final remaining = remainingSeconds(period, epochSeconds);
    return remaining / period;
  }

  String formatCode(int code, int digits) {
    final raw = code.toString().padLeft(digits, '0');
    if (digits == 6) {
      return '${raw.substring(0, 3)} ${raw.substring(3)}';
    }
    if (digits == 8) {
      return '${raw.substring(0, 4)} ${raw.substring(4)}';
    }
    return raw;
  }

  TOTP _buildTotp(TotpAccount account) {
    return TOTP(
      secret: TotpAccount.normalizeSecret(account.secret),
      digits: account.digits,
      algorithm: account.algorithm.toOtpAuth,
      period: account.period,
    );
  }
}
