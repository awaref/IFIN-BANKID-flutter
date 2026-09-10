/// Validates animated BankID QR payloads.
///
/// Expected format: `bankid.<uuid>.<seconds>.<hmac64hex>`
/// Regex: `^[a-z0-9]+\.[0-9a-f-]{36}\.[0-9]+\.[0-9a-f]{64}$`
class QrPayloadParser {
  QrPayloadParser._();

  static final RegExp animatedPayloadPattern = RegExp(
    r'^[a-z0-9]+\.[0-9a-f-]{36}\.[0-9]+\.[0-9a-f]{64}$',
    caseSensitive: false,
  );

  /// Returns true if [raw] matches the animated QR payload format.
  static bool isValidAnimatedPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return false;
    return animatedPayloadPattern.hasMatch(trimmed);
  }

  /// Returns true if [raw] looks like a legacy static token
  /// (no dots / not 4 segments) rather than an animated payload.
  static bool looksLikeLegacyToken(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return true;
    final parts = trimmed.split('.');
    if (parts.length != 4) return true;
    return !isValidAnimatedPayload(trimmed);
  }

  /// Normalize payload for API (trim only — never strip prefix or recompute HMAC).
  static String normalize(String raw) => raw.trim();
}
