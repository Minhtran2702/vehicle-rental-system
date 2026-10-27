import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_provider.dart';
import 'core/theme.dart';
import 'router.dart';

class CarRentalApp extends StatefulWidget {
  const CarRentalApp({super.key});

  @override
  State<CarRentalApp> createState() => _CarRentalAppState();
}

class _CarRentalAppState extends State<CarRentalApp> {
  late final router = buildRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Car Rental',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: router,
    );
  }
}
