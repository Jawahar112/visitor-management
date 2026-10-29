import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management/domain/entities/visitor_entity.dart';
import 'package:visitor_management/presentation/screens/dashboard_screen.dart';
import 'package:visitor_management/presentation/screens/home_shell.dart';
import 'package:visitor_management/presentation/screens/qr_scanner_screen.dart';
import 'package:visitor_management/presentation/screens/visitor_details_screen.dart';
import 'package:visitor_management/presentation/screens/visitor_form_screen.dart';
import 'package:visitor_management/presentation/screens/visitor_list_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/visitors',
            builder: (_, __) => const VisitorListScreen(),
            routes: [
              GoRoute(
                path: 'register',
                parentNavigatorKey: _rootKey, // bar hidden
                builder: (_, s) =>  VisitorFormScreen(visitor: s.extra as VisitorEntity?),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootKey, // bar hidden
                builder: (_, s) =>
                    VisitorDetailsScreen(visitorId: s.pathParameters['id']!)
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/scan', builder: (_, __) => const QrScannerScreen()),
        ]),
      ],
    ),
  ],
);