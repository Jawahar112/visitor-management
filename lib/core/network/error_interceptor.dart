import 'package:dio/dio.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/core/exceptions/app_exceptions.dart';

const kSilent = 'silent';

class ErrorInterceptor extends Interceptor {
  final void Function()? onUnauthorized; // e.g. clear token + go to login
  ErrorInterceptor({this.onUnauthorized});

  String? _lastMessage;
  DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ex = _map(err);

    final showGlobally = ex is NetworkException ||
        ex is TimeoutAppException ||
        ex is ServerException ||
        ex is UnauthorizedException;

    final silent = err.requestOptions.extra[kSilent] == true;

    if (showGlobally && !silent) {
      _show(ex.message);
      ex.handled = true;
    }

    if (ex is UnauthorizedException) onUnauthorized?.call();

    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ex, 
    ));
  }

  AppException _map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutAppException();
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.cancel:
        return AppException('Request cancelled.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final serverMsg = _serverMessage(e.response?.data);
        if (code == 401) return UnauthorizedException();
        if (code != null && code >= 500) {
          return ServerException(serverMsg ?? 'Server error. Please try again later.', code);
        }
        return AppException(serverMsg ?? 'Request failed ($code).', statusCode: code);
      default:
        return AppException('Something went wrong. Please try again............');
    }
  }

  String? _serverMessage(dynamic data) {
    if (data is Map) {
      final m = data['message'] ?? data['error'];
      if (m is String && m.isNotEmpty) return m;
    }
    return null;
  }

  void _show(String message) {
    final now = DateTime.now();
    if (message == _lastMessage &&
        now.difference(_lastShown) < const Duration(seconds: 3)) {
      return;
    }
    _lastMessage = message;
    _lastShown = now;
    showGlobalSnack(message);
  }
}