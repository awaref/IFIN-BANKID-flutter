import 'package:bankid_app/models/qr_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QrScanResponse', () {
    test('parses relying_party, intent, nullable user_visible_data', () {
      final json = {
        'approval_ref': 'AbCd123',
        'intent': 'auth',
        'user_visible_data': null,
        'expires_at': '2026-03-26T12:05:00+00:00',
        'relying_party': {
          'id': 'rp-1',
          'name': 'Tayseer',
          'domain': 'tayseer.example',
          'logo_url': null,
        },
        'requires_approval': true,
      };

      final response = QrScanResponse.fromJson(json);
      expect(response.approvalRef, 'AbCd123');
      expect(response.intent, 'auth');
      expect(response.isSignIntent, isFalse);
      expect(response.userVisibleData, isNull);
      expect(response.relyingParty.name, 'Tayseer');
      expect(response.relyingParty.domain, 'tayseer.example');
      expect(response.requiresApproval, isTrue);
      expect(response.expiresAtDateTime, isNotNull);
    });

    test('parses sign intent with user_visible_data and logo', () {
      final json = {
        'approval_ref': 'XyZ',
        'intent': 'sign',
        'user_visible_data': 'Transfer 100 SAR to Ali',
        'expires_at': '2026-03-26T12:05:00+00:00',
        'relying_party': {
          'id': 'rp-2',
          'name': 'Partner Bank',
          'domain': 'partner.example',
          'logo_url': 'https://example.com/logo.png',
        },
        'requires_approval': true,
      };

      final response = QrScanResponse.fromJson(json);
      expect(response.isSignIntent, isTrue);
      expect(response.userVisibleData, 'Transfer 100 SAR to Ali');
      expect(response.relyingParty.logoUrl, 'https://example.com/logo.png');
    });

    test('QrApproveResponse parses order map', () {
      final json = {
        'message': 'Authentication approved',
        'order': {
          'status': 'complete',
          'intent': 'auth',
          'completed_at': '2026-03-26T12:06:00+00:00',
        },
      };
      final response = QrApproveResponse.fromJson(json);
      expect(response.message, 'Authentication approved');
      expect(response.order?['status'], 'complete');
    });
  });
}
