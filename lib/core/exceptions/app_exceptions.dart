
class AppException implements Exception {
  final String message;
  final int? statusCode;

  bool handled;

  AppException(this.message, {this.statusCode, this.handled = false});

  @override
  String toString() => message;
}


class NotFoundException extends AppException {
  NotFoundException([super.message = 'Visitor not found.'])
      : super(statusCode: 404);
}
class BusinessRuleException extends AppException {
  BusinessRuleException(
    super.message, {
    super.statusCode,
  });
}


class NetworkException extends AppException {
  NetworkException([super.message = 'Network error.']);
}

class TimeoutAppException extends AppException {
  TimeoutAppException([super.message = 'Request timed out. Please try again.']);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Session expired. Please log in again.'])
      : super(statusCode: 401);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error. Please try again later.', int? code])
      : super(statusCode: code);
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  ValidationException(super.message,
      {this.fieldErrors = const {}, super.statusCode});
}

class ForbiddenException extends AppException {
  ForbiddenException([super.message = 'You do not have permission to do this.'])
      : super(statusCode: 403);
}

class RateLimitException extends AppException {
  RateLimitException([super.message = 'Too many requests. Please wait a moment.'])
      : super(statusCode: 429);
}

class CancelledException extends AppException {
  CancelledException([super.message = 'Request cancelled.']);
}

class PermissionException extends AppException {
  PermissionException([super.message = 'Permission denied. Enable it in Settings.']);
}

class ParsingException extends AppException {
  ParsingException([super.message = 'Received invalid data. Please try again.']);
}

class StorageException extends AppException {
  StorageException([super.message = 'Could not read or save data on this device.']);
}

class UnknownException extends AppException {
  UnknownException([super.message = 'Something went wrong. Please try again.']);
}