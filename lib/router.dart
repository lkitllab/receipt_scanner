import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import './app_flow/home_screen.dart';
import './app_flow/receipt_details_screen.dart';
import './app_flow/lineitem_screen.dart';

enum AppRoute {
  main,
  receiptDetails,
  lineitemDetails,
}

extension Sss on AppRoute {
  String path() {
    switch (this) {
      case AppRoute.main:
        return '/';
      case AppRoute.receiptDetails:
        return 'receiptDetails';
      case AppRoute.lineitemDetails:
        return 'lineitemDetails';
      default:
        return '/';
    }
  }
}

class AppRouter {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: [
        GoRoute(
          name: AppRoute.receiptDetails.path(),
          path: '${AppRoute.receiptDetails.path()}/:rid',
          builder: (BuildContext context, GoRouterState state) {
            final receiptId = state.pathParameters['rid']!;
            return ReceiptDetailsScreen(receiptId);
          },
          routes: [
            GoRoute(
              name: AppRoute.lineitemDetails.path(),
              path: '${AppRoute.lineitemDetails.path()}/:lid',
              builder: (BuildContext context, GoRouterState state) {
                final receiptId = state.pathParameters['rid']!;
                final lineItemId = state.pathParameters['lid']!;
                return LineItemScreen(
                  receiptId: receiptId,
                  lineItemId: lineItemId,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ]);
}
