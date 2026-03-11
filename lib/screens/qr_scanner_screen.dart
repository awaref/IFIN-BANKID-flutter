import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/providers/auth_provider.dart';
import 'package:bankid_app/screens/qr_auth_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  bool _showSuccessIndicator = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final authRepo = authProvider.authRepository;
      final response = await authRepo.scanQrCode(code);

      if (!mounted) {
        return;
      }

      if (mounted) {
        if (response.sessionToken.isNotEmpty) {
          setState(() {
            _isScanning = false;
            _showSuccessIndicator = true;
          });
          await Future.delayed(const Duration(milliseconds: 1500)); // Show success indicator for 1.5 seconds
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QrAuthScreen(
                sessionToken: response.sessionToken,
                partnerWebsite: response.partnerWebsite,
                requiresApproval: response.requiresApproval,
              ),
            ),
          );
        } else {
          _showError(AppLocalizations.of(context)!.qrInvalidCode);
        }
      }
    } catch (e) {
      if (mounted) {
        String message = AppLocalizations.of(context)!.qrAuthError;
        
        if (e is NetworkException) {
          message = AppLocalizations.of(context)!.noInternetConnectionTitle; 
        } else if (e is UnauthorizedException) {
          message = AppLocalizations.of(context)!.qrSessionExpired;
        } else if (e is ServerException) {
           message = '${AppLocalizations.of(context)!.authenticationError} (500)';
        } else if (e is ApiException) {
           if (e.statusCode == 404) {
             message = AppLocalizations.of(context)!.qrSessionExpired;
           } else {
             message = e.message;
           }
        }
        
        _showError(message);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Add a small delay before re-enabling scanning to avoid rapid loops
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrScanTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scanner Overlay
          Center(
            child: SizedBox(
              width: 250.w,
              height: 250.w,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScannerOverlayPainter(_animation.value),
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: Text(
              l10n.qrScanInstructions,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                shadows: const [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccessIndicator)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showSuccessIndicator ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: const Color(0xFF37C293),
                      size: 100.sp,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double animationValue;

  ScannerOverlayPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(12.r)));

    canvas.drawPath(path, paint);

    // Draw scanning line
    final linePaint = Paint()
      ..color = const Color(0xFF37C293)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final lineY = size.height * animationValue;
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
