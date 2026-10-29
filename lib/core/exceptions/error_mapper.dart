import 'dart:async';
import 'dart:io' show SocketException, HttpException, HandshakeException, FileSystemException;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/core/exceptions/app_exceptions.dart';

AppException mapError(Object e) {
  if (e is AppException) return e;
  

  if (e is SocketException) return NetworkException();
  if (e is HandshakeException) return AppException('Secure connection failed.');
  if (e is HttpException) return NetworkException('Could not reach the server.');
  if (e is TimeoutException) return TimeoutAppException();

  if (e is FormatException) return ParsingException();
  if (e is TypeError) return ParsingException(); // e.g. null / wrong type in fromJson

  if (e is FileSystemException) return StorageException();

  if (e is MobileScannerException) {
    switch (e.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return PermissionException('Camera permission denied. Enable it in Settings.');
      case MobileScannerErrorCode.unsupported:
        return AppException('Camera is not supported on this device.');
      default:
        return AppException('Could not start the camera.');
    }
  }

  if (e is MissingPluginException) {
    return AppException('This feature is not available on this device.');
  }
  if (e is PlatformException) {
    final code = e.code.toLowerCase();
    if (code.contains('denied') || code.contains('permission')) {
      return PermissionException();
    }
    return AppException(e.message ?? 'A device error occurred (${e.code}).');
  }

  if (e is StateError || e is ArgumentError || e is UnsupportedError || e is RangeError) {
    return UnknownException();
  }

  return UnknownException();
}

void reportError(Object e, [StackTrace? st, bool show = true]) {
  final ex = mapError(e);
  debugPrint('Error: $e\n${st ?? ''}');
  if (show && !ex.handled) {
    showGlobalSnack(ex.message);
    ex.handled = true;
  }
}


