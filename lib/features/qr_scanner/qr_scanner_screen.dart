// lib/features/qr_scanner/qr_scanner_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:secondmind/core/theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key, this.onCodeScanned});

  final Function(String)? onCodeScanned;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController _controller;
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isScanning = true;
  String? _scannedCode;
  bool _isFlashOn = false;
  bool _isCameraReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initScanner();
    _initAnimations();
  }

  void _initScanner() {
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.normal,
    );
    
    // مراقبة حالة الكاميرا
    _controller.start().then((_) {
      if (mounted) setState(() => _isCameraReady = true);
    }).catchError((error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    setState(() => _isFlashOn = !_isFlashOn);
    await _controller.toggleTorch();
  }

  Future<void> _switchCamera() async {
    await _controller.switchCamera();
    HapticFeedback.selectionClick();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        _isScanning = false;
        setState(() => _scannedCode = barcode.rawValue);
        
        HapticFeedback.heavyImpact();
        _showScannedDialog(barcode.rawValue!);
        return;
      }
    }
  }

  void _showScannedDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.statusCompleted, size: 28),
            const SizedBox(width: 12),
            Text('تم المسح بنجاح', style: AppTheme.headlineMd.copyWith(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('تم قراءة الرمز بنجاح:', style: AppTheme.bodyMd),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                code,
                style: AppTheme.bodyLg.copyWith(
                  color: AppTheme.primary,
                  fontFamily: Platform.isWindows ? 'monospace' : null,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: Text('مسح مرة أخرى', style: AppTheme.labelMd.copyWith(color: AppTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onCodeScanned != null) {
                widget.onCodeScanned!(code);
              }
              Navigator.pop(context);
              Navigator.pop(context);
              Get.snackbar(
                'نجاح',
                'تم إضافة الرمز إلى حقل التحليل',
                backgroundColor: AppTheme.primary,
                colorText: AppTheme.onPrimary,
                snackPosition: SnackPosition.TOP,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('استخدام الرمز'),
          ),
        ],
      ),
    );
  }

  void _resetScanner() {
    _isScanning = true;
    setState(() => _scannedCode = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('مسح رمز QR'),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        if (_isCameraReady) ...[
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                key: ValueKey(_isFlashOn),
                color: Colors.white,
              ),
            ),
            onPressed: _toggleFlash,
            tooltip: 'إضاءة',
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: _switchCamera,
            tooltip: 'تبديل الكاميرا',
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }
    
    return Stack(
      children: [
        // كاميرا المسح
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        
        // تراكب الشاشة
        _buildScannerOverlay(),
        
        // أزرار التحكم السفلية
        if (_isCameraReady) _buildControlButtons(),
        
        // حالة المسح
        if (!_isScanning)
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'تم المسح بنجاح!',
                style: AppTheme.labelMd.copyWith(color: AppTheme.statusCompleted),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 40, color: AppTheme.error),
          ),
          const SizedBox(height: 20),
          Text(
            'تعذر الوصول إلى الكاميرا',
            style: AppTheme.headlineMd.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'يرجى التأكد من منح صلاحية الكاميرا',
            style: AppTheme.bodyMd.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _initScanner();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          // خلفية مظلمة
          Container(color: Colors.black.withValues(alpha: 0.6)),
          
          // منطقة المسح (شفافة)
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary, width: 3),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // خط المسح المتحرك
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            top: MediaQuery.of(context).size.width * 0.75 * _scanAnimation.value - 2,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppTheme.primary,
                                    AppTheme.secondary!,
                                    AppTheme.primary,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // زوايا الإطار
                      _buildCorner(Alignment.topLeft, -12, -12, 'left', 'top'),
                      _buildCorner(Alignment.topRight, 12, -12, 'right', 'top'),
                      _buildCorner(Alignment.bottomLeft, -12, 12, 'left', 'bottom'),
                      _buildCorner(Alignment.bottomRight, 12, 12, 'right', 'bottom'),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // نص إرشادي
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _isScanning ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 32, color: Colors.white70),
                  const SizedBox(height: 12),
                  Text(
                    'ضع الرمز داخل الإطار للمسح',
                    style: AppTheme.bodyLg.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, double xOffset, double yOffset, String horizontal, String vertical) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: Offset(xOffset, yOffset),
        child: SizedBox(
          width: 40,
          height: 40,
          child: CustomPaint(
            painter: CornerPainter(
              color: AppTheme.primary,
              horizontal: horizontal,
              vertical: vertical,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زر الإضاءة
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleFlash,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              // زر تبديل الكاميرا
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _switchCamera,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// رسم زوايا الإطار
class CornerPainter extends CustomPainter {
  final Color color;
  final String horizontal;
  final String vertical;
  final double size;

  CornerPainter({
    required this.color,
    required this.horizontal,
    required this.vertical,
    this.size = 40,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lineLength = this.size * 0.6;

    if (horizontal == 'left') {
      canvas.drawLine(Offset(0, 0), Offset(lineLength, 0), paint);
      canvas.drawLine(Offset(0, 0), Offset(0, lineLength), paint);
    } else if (horizontal == 'right') {
      canvas.drawLine(Offset(this.size, 0), Offset(this.size - lineLength, 0), paint);
      canvas.drawLine(Offset(this.size, 0), Offset(this.size, lineLength), paint);
    }
    
    if (vertical == 'bottom') {
      if (horizontal == 'left') {
        canvas.drawLine(Offset(0, this.size), Offset(lineLength, this.size), paint);
        canvas.drawLine(Offset(0, this.size), Offset(0, this.size - lineLength), paint);
      } else if (horizontal == 'right') {
        canvas.drawLine(Offset(this.size, this.size), Offset(this.size - lineLength, this.size), paint);
        canvas.drawLine(Offset(this.size, this.size), Offset(this.size, this.size - lineLength), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}