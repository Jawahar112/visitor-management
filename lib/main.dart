import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management/common/utils/ui_helpers.dart';
import 'package:visitor_management/core/app_router.dart';
import 'package:visitor_management/core/exceptions/error_mapper.dart';

import 'core/theme.dart';

void main() {
  GoRouter.optionURLReflectsImperativeAPIs = true; 
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details); // keep console output
  };

  // async errors 
  PlatformDispatcher.instance.onError = (error, stack) {
    reportError(error, stack);
    return true; // handled
  };

  runApp(ProviderScope(
    observers: [ErrorProviderObserver()],
    child: const VisitorApp(),
  ));
}

/// Riverpod providers errors
class ErrorProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(ProviderBase<Object?> provider, Object error,
      StackTrace stackTrace, ProviderContainer container) {
    reportError(error, stackTrace, false); 
  }
}

class VisitorApp extends StatelessWidget {
  const VisitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: rootMessengerKey,
      title: 'Visitor Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}