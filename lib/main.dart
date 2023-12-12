import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import './router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerConfig: AppRouter().router,
    );
  }
}