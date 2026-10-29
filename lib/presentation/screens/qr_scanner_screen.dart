import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_management/core/exceptions/app_exceptions.dart';
import 'package:visitor_management/presentation/providers/visitor_providers.dart';



class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  // Visitor IDs from the API are short alphanumeric tokens.
  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_\-]{1,64}$');

  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// Guards against repeated scanner callbacks: while a scan is being
  /// processed (or its error is on screen) every further callback is ignored.
  bool _handling = false;
  bool _lookingUp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling || capture.barcodes.isEmpty) return;
    _handling = true; // set synchronously, before any await

    final notifier = ref.read(visitorListProvider.notifier);
    final raw = capture.barcodes.first.rawValue?.trim() ?? '';

    if (!_idPattern.hasMatch(raw)) {
      await _showError('Invalid QR code. This is not a visitor pass.');
      return;
    }

    setState(() {
      _lookingUp = true;
      _errorMessage = null;
    });

    try {
      final visitor = await notifier.fetchById(raw);
      if (!mounted) return;
      setState(() => _lookingUp = false);

      await _safely(_controller.stop);
      if (!mounted) return;
      context.go('/visitors/${visitor.id}');
      if (!mounted) return;
      await _safely(_controller.start);
      _handling = false;
    } on NotFoundException {
      await _showError('Visitor not found for this QR code.');
    } on AppException catch (e) {
      await _showError(e.message);
    } catch (_) {
      await _showError('Could not read this QR code. Please try again.');
    }
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;
    setState(() {
      _lookingUp = false;
      _errorMessage = message;
    });
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _errorMessage = null);
    _handling = false;
  }

  Future<void> _safely(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Starting/stopping an already started/stopped camera is harmless.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            tooltip: 'Toggle flash',
            icon: const Icon(Icons.flash_on),
            onPressed: () => _safely(_controller.toggleTorch),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) => _CameraError(
              error: error,
              onRetry: () => _safely(_controller.start),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _errorMessage != null ? Colors.redAccent : Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: _Banner(
                text: _errorMessage ??
                    (_lookingUp
                        ? 'Looking up visitor…'
                        : 'Point the camera at a visitor QR code'),
                isError: _errorMessage != null,
                showSpinner: _lookingUp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner(
      {required this.text, required this.isError, required this.showSpinner});
  final String text;
  final bool isError;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade700 : Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ] else if (isError) ...[
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onRetry});
  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(denied ? Icons.no_photography : Icons.videocam_off,
                color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            Text(
              denied ? 'Camera permission denied' : 'Camera is unavailable',
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              denied
                  ? 'Allow camera access to scan visitor QR codes: '
                      'Settings › Apps › Visitor Management › Permissions › Camera.'
                  : '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
