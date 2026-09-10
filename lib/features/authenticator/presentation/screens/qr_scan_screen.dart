import 'dart:async';
import 'dart:math' as math;

import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../data/services/otp_uri_parser.dart';
import '../providers/authenticator_provider.dart';
import '../providers/timer_provider.dart';
import 'account_preview_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _scanLineController;
  final OtpUriParser _parser = OtpUriParser();

  bool _permissionChecking = true;
  bool _permissionDenied = false;
  bool _isProcessing = false;
  bool _showSuccess = false;
  String? _errorMessage;
  Timer? _errorClearTimer;

  static const _errorCooldown = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController(
      autoStart: false,
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 400,
      facing: CameraFacing.back,
      autoZoom: true,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _ensurePermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _errorClearTimer?.cancel();
    _scanLineController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_permissionDenied || _permissionChecking) return;
    if (!_controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(_controller.stop());
      case AppLifecycleState.resumed:
        if (!_isProcessing && !_showSuccess) {
          unawaited(_controller.start());
        }
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _ensurePermission() async {
    setState(() {
      _permissionChecking = true;
      _permissionDenied = false;
    });

    final status = await Permission.camera.request();
    if (!mounted) return;

    final granted = status.isGranted || status.isLimited;
    setState(() {
      _permissionChecking = false;
      _permissionDenied = !granted;
    });

    if (granted) {
      try {
        await _controller.start();
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              AppLocalizations.of(context)!.authenticatorCameraUnavailable;
        });
      }
    }
  }

  Rect _scanWindowFor(Size layoutSize) {
    final side = math.min(layoutSize.width * 0.72, 280.0);
    return Rect.fromCenter(
      center: Offset(layoutSize.width / 2, layoutSize.height * 0.42),
      width: side,
      height: side,
    );
  }

  String? _extractPayload(BarcodeCapture capture) {
    String? fallback;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      final display = barcode.displayValue?.trim();
      final value = (raw != null && raw.isNotEmpty)
          ? raw
          : (display != null && display.isNotEmpty ? display : null);
      if (value == null) continue;
      if (value.toLowerCase().startsWith('otpauth://')) {
        return value;
      }
      fallback ??= value;
    }
    return fallback;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _showSuccess || _permissionDenied) return;

    final value = _extractPayload(capture);
    if (value == null || value.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    _errorClearTimer?.cancel();

    try {
      final account = _parser.parse(value);
      if (!mounted) return;

      await HapticFeedback.mediumImpact();
      await _controller.pause();
      setState(() => _showSuccess = true);
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: context.read<AuthenticatorProvider>(),
              ),
              ChangeNotifierProvider.value(
                value: context.read<TimerProvider>(),
              ),
            ],
            child: AccountPreviewScreen(account: account),
          ),
        ),
      );
    } on OtpUriParseException catch (e) {
      await _handleScanError(e.message);
    } catch (_) {
      if (!mounted) return;
      await _handleScanError(
        AppLocalizations.of(context)!.authenticatorInvalidQr,
      );
    }
  }

  Future<void> _handleScanError(String message) async {
    await HapticFeedback.heavyImpact();
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      _isProcessing = false;
      _showSuccess = false;
    });
    _errorClearTimer?.cancel();
    _errorClearTimer = Timer(_errorCooldown, () {
      if (!mounted) return;
      setState(() => _errorMessage = null);
    });
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      // Device may not have a torch.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (_permissionChecking) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(l10n.authenticatorScanQr),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.authenticatorScanQr)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.no_photography_outlined,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.authenticatorCameraPermission,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: openAppSettings,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.authenticatorOpenSettings),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _ensurePermission,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(l10n.authenticatorScanQr),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.authenticatorManualEntry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.authenticatorScanQr),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final torch = state.torchState;
              if (torch == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              final on = torch == TorchState.on || torch == TorchState.auto;
              return IconButton(
                tooltip: l10n.authenticatorTorchToggle,
                onPressed: _toggleTorch,
                icon: Icon(
                  on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  color: on ? Colors.amber : Colors.white,
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final layoutSize = constraints.biggest;
          final scanWindow = _scanWindowFor(layoutSize);

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                fit: BoxFit.cover,
                scanWindow: scanWindow,
                onDetect: _onDetect,
                errorBuilder: (context, error) {
                  return ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white70,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.authenticatorCameraUnavailable,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.authenticatorManualEntry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _scanLineController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _QrViewfinderPainter(
                          scanWindow: scanWindow,
                          scanLineProgress: _scanLineController.value,
                          errorActive: _errorMessage != null,
                          successActive: _showSuccess,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: MediaQuery.paddingOf(context).bottom + 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _errorMessage != null
                          ? Container(
                              key: ValueKey(_errorMessage),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Text(
                              key: const ValueKey('instructions'),
                              l10n.authenticatorScanInstructions,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedEdit02,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(l10n.authenticatorManualEntry),
                    ),
                  ],
                ),
              ),
              if (_isProcessing && !_showSuccess)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              if (_showSuccess)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0x88000000),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF37C293),
                            size: 88,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.authenticatorScanSuccess,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QrViewfinderPainter extends CustomPainter {
  _QrViewfinderPainter({
    required this.scanWindow,
    required this.scanLineProgress,
    required this.errorActive,
    required this.successActive,
  });

  final Rect scanWindow;
  final double scanLineProgress;
  final bool errorActive;
  final bool successActive;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, const Radius.circular(18)),
      );
    final dimmed = Path.combine(PathOperation.difference, overlay, cutout);
    canvas.drawPath(
      dimmed,
      Paint()..color = const Color(0x99000000),
    );

    final accent = successActive
        ? const Color(0xFF37C293)
        : errorActive
            ? const Color(0xFFFF6B6B)
            : Colors.white;

    final borderPaint = Paint()
      ..color = accent.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cornerLen = math.min(scanWindow.width, scanWindow.height) * 0.18;
    final tl = scanWindow.topLeft;
    final tr = scanWindow.topRight;
    final bl = scanWindow.bottomLeft;
    final br = scanWindow.bottomRight;

    // Corner brackets.
    canvas.drawPath(
      Path()
        ..moveTo(tl.dx, tl.dy + cornerLen)
        ..lineTo(tl.dx, tl.dy)
        ..lineTo(tl.dx + cornerLen, tl.dy),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tr.dx - cornerLen, tr.dy)
        ..lineTo(tr.dx, tr.dy)
        ..lineTo(tr.dx, tr.dy + cornerLen),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(bl.dx, bl.dy - cornerLen)
        ..lineTo(bl.dx, bl.dy)
        ..lineTo(bl.dx + cornerLen, bl.dy),
      borderPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(br.dx - cornerLen, br.dy)
        ..lineTo(br.dx, br.dy)
        ..lineTo(br.dx, br.dy - cornerLen),
      borderPaint,
    );

    if (!successActive) {
      final y = scanWindow.top +
          (scanWindow.height - 2) * scanLineProgress +
          1;
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            accent.withValues(alpha: 0),
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromLTWH(scanWindow.left, y - 1, scanWindow.width, 2),
        )
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(scanWindow.left + 10, y),
        Offset(scanWindow.right - 10, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QrViewfinderPainter oldDelegate) {
    return oldDelegate.scanLineProgress != scanLineProgress ||
        oldDelegate.scanWindow != scanWindow ||
        oldDelegate.errorActive != errorActive ||
        oldDelegate.successActive != successActive;
  }
}
