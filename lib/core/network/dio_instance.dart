import 'package:dio/dio.dart';
import 'package:visitor_management/core/app_config.dart';
import 'package:visitor_management/core/network/error_interceptor.dart';

final dio =
    Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.timeout,
          sendTimeout: AppConfig.timeout,
          receiveTimeout: AppConfig.timeout,
          headers: {'Content-Type': 'application/json'},
        ),
      )
      ..interceptors.add(
        ErrorInterceptor(
          onUnauthorized: () {
            // clear token, then redirect, e.g. appRouter.go('/login');
          },
        ),
      );
