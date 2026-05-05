import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    // ProviderScope: "Nha may" Riverpod - Bat buoc phai boc ngoai cung
    const ProviderScope(
      child: PlantCareApp(),
    ),
  );
}

class PlantCareApp extends ConsumerWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.read thay vi ref.watch -> GoRouter chi tao 1 lan, khong bi recreate
    final router = ref.read(appRouterProvider);

    return MaterialApp.router(
      title: 'PlantCare',
      debugShowCheckedModeBanner: false,

      // Cai dat bo nhan dien duong dan tu GoRouter
      routerConfig: router,

      // Theme chung cho toan app
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          background: AppColors.background,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
    );
  }
}
