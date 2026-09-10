import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bankid_app/core/utils/app_logger.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/screens/qr_auth_screen.dart';
import 'package:bankid_app/services/qr_auth_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Handles `ifinbankid:///?autostarttoken=<uuid>` same-device login.
class AutostartLinkService {
  AutostartLinkService._();
  static final AutostartLinkService instance = AutostartLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  String? _pendingAutostartToken;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _handling = false;

  String? get pendingAutostartToken => _pendingAutostartToken;

  void clearPending() => _pendingAutostartToken = null;

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _onUri(initial);
      }
    } catch (e) {
      AppLogger.log('Autostart initial link error: $e');
    }

    await _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      _onUri,
      onError: (e) => AppLogger.log('Autostart link stream error: $e'),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  void _onUri(Uri uri) {
    final token = extractAutostartToken(uri);
    if (token == null || token.isEmpty) {
      AppLogger.log('Autostart: ignored URI (no token)');
      return;
    }
    AppLogger.log('Autostart: received token_len=${token.length}');
    handleAutostartToken(token);
  }

  /// Extract token from:
  /// - `ifinbankid:///?autostarttoken=UUID`
  /// - `ifinbankid://autostart?token=UUID`
  static String? extractAutostartToken(Uri uri) {
    if (uri.scheme.toLowerCase() != 'ifinbankid') return null;

    final autostart = uri.queryParameters['autostarttoken'] ??
        uri.queryParameters['autostartToken'];
    if (autostart != null && autostart.isNotEmpty) return autostart;

    final token = uri.queryParameters['token'];
    if (token != null &&
        token.isNotEmpty &&
        (uri.host.toLowerCase() == 'autostart' ||
            uri.path.toLowerCase().contains('autostart'))) {
      return token;
    }
    return null;
  }

  Future<void> handleAutostartToken(String token) async {
    final nav = _navigatorKey?.currentState;
    final context = _navigatorKey?.currentContext;
    if (nav == null || context == null) {
      _pendingAutostartToken = token;
      return;
    }

    AuthProvider? auth;
    try {
      auth = Provider.of<AuthProvider>(context, listen: false);
    } catch (_) {
      _pendingAutostartToken = token;
      return;
    }

    final accessToken = await auth.authRepository.getToken();
    if (accessToken == null) {
      _pendingAutostartToken = token;
      AppLogger.log('Autostart: stashed until user is logged in');
      return;
    }

    if (!context.mounted) {
      _pendingAutostartToken = token;
      return;
    }
    await _openConfirm(context, auth, token);
  }

  /// Call after splash/login when a pending token may exist.
  Future<void> processPendingIfAny(BuildContext context) async {
    final token = _pendingAutostartToken;
    if (token == null || token.isEmpty) return;
    _pendingAutostartToken = null;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final accessToken = await auth.authRepository.getToken();
    if (accessToken == null) {
      _pendingAutostartToken = token;
      return;
    }
    if (!context.mounted) {
      _pendingAutostartToken = token;
      return;
    }
    await _openConfirm(context, auth, token);
  }

  Future<void> _openConfirm(
    BuildContext context,
    AuthProvider auth,
    String token,
  ) async {
    if (_handling) return;
    _handling = true;
    try {
      final response = await auth.authRepository.autostartQr(token);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QrAuthScreen(scanResponse: response),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      final message = QrAuthErrorMapper.messageFor(context, e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      QrAuthErrorMapper.navigateToKycIfNeeded(context, e);
    } finally {
      _handling = false;
    }
  }
}
