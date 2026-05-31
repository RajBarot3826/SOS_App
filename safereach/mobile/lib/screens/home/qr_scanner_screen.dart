/// QR Scanner Screen — Camera-based location QR code scanner
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:safereach/config/routes.dart';
import 'package:safereach/config/theme.dart';
import 'package:safereach/services/qr_scanner_service.dart';
import 'package:safereach/services/location_service.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessing = false;
  QRLocationData? _scannedLocation;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _onQRDetected,
          ),

          // Dark overlay with scan window
          _buildOverlay(),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Scan Campus QR Code',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => _scannerController.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_2, color: Colors.white54, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Point camera at a SafeReach QR code',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your location will be set automatically',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Scanned result overlay
          if (_scannedLocation != null) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildResultOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SafeReachTheme.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SafeReachTheme.safeGreen.withValues(alpha: 0.5), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SafeReachTheme.safeGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: SafeReachTheme.safeGreen, size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Location Found!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  _scannedLocation!.displayName,
                  style: const TextStyle(color: SafeReachTheme.darkTextSecondary, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_scannedLocation!.building} • Floor ${_scannedLocation!.floor}',
                  style: TextStyle(color: SafeReachTheme.darkTextSecondary.withValues(alpha: 0.7), fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _confirmLocation,
                    icon: const Icon(Icons.location_on),
                    label: const Text('Set as My Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SafeReachTheme.safeGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() {
                    _scannedLocation = null;
                    _isProcessing = false;
                  }),
                  child: const Text('Scan Again', style: TextStyle(color: SafeReachTheme.accentBlue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    final qrService = ref.read(qrScannerServiceProvider);
    final location = qrService.processQRCode(rawValue);

    if (location != null) {
      setState(() => _scannedLocation = location);
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code. Please scan a SafeReach location code.'),
          backgroundColor: SafeReachTheme.warningOrange,
        ),
      );
    }
  }

  void _confirmLocation() {
    if (_scannedLocation == null) return;

    final locationService = ref.read(locationServiceProvider);
    locationService.setFromQR(
      latitude: _scannedLocation!.latitude,
      longitude: _scannedLocation!.longitude,
      locationName: _scannedLocation!.displayName,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location set: ${_scannedLocation!.displayName}'),
        backgroundColor: SafeReachTheme.safeGreen,
      ),
    );

    context.go(AppRoutes.home);
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final scanSize = size.width * 0.7;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2.5;
    final scanRect = Rect.fromLTWH(left, top, scanSize, scanSize);

    // Draw dark overlay with cutout
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20))),
      ),
      paint,
    );

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = SafeReachTheme.accentBlue
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    const cornerLen = 30.0;
    final r = scanRect;
    
    // Top-left
    canvas.drawLine(Offset(r.left, r.top + cornerLen), Offset(r.left, r.top + 10), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(r.left, r.top, 20, 20), 3.14, 1.57, false, cornerPaint);
    canvas.drawLine(Offset(r.left + 10, r.top), Offset(r.left + cornerLen, r.top), cornerPaint);
    
    // Top-right
    canvas.drawLine(Offset(r.right - cornerLen, r.top), Offset(r.right - 10, r.top), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(r.right - 20, r.top, 20, 20), -1.57, 1.57, false, cornerPaint);
    canvas.drawLine(Offset(r.right, r.top + 10), Offset(r.right, r.top + cornerLen), cornerPaint);
    
    // Bottom-left
    canvas.drawLine(Offset(r.left, r.bottom - cornerLen), Offset(r.left, r.bottom - 10), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(r.left, r.bottom - 20, 20, 20), 1.57, 1.57, false, cornerPaint);
    canvas.drawLine(Offset(r.left + 10, r.bottom), Offset(r.left + cornerLen, r.bottom), cornerPaint);
    
    // Bottom-right
    canvas.drawLine(Offset(r.right - cornerLen, r.bottom), Offset(r.right - 10, r.bottom), cornerPaint);
    canvas.drawArc(Rect.fromLTWH(r.right - 20, r.bottom - 20, 20, 20), 0, 1.57, false, cornerPaint);
    canvas.drawLine(Offset(r.right, r.bottom - cornerLen), Offset(r.right, r.bottom - 10), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
