import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/admin/screens/admin_login_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/diagnosis/screens/diagnosis_screen.dart';
import '../../features/diagnosis/screens/diagnosis_history_screen.dart';
import '../../features/garden/screens/garden_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';
import '../../core/storage/secure_storage.dart';

/// GoRouter SINGLETON - chi tao 1 lan duy nhat, KHONG bi recreate
/// Su dung async redirect thay vi watch Provider de tranh reset ve initialLocation
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: false,

    // redirect co the la async (FutureOr<String?>) - GoRouter ho tro
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      // === ADMIN ROUTES: HOAN TOAN BYPASS - khong ap dung bat ky rule nao ===
      if (loc.startsWith('/admin')) return null;

      // === USER ROUTES: Kiem tra JWT Token ===
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final isAuthRoute = loc == '/login' || loc == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';

      return null;
    },

    routes: [
      // === AUTH (User) ===
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // === MAIN APP (Co Bottom Navigation Bar) ===
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Nhanh 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          
          // Nhanh 1: Posts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/posts',
                name: 'posts',
                builder: (context, state) => const _ComingSoon(title: 'Bai dang'),
              ),
            ],
          ),

          // Nhanh 2: Diagnosis
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/diagnosis',
                name: 'diagnosis',
                builder: (context, state) => const DiagnosisScreen(),
              ),
            ],
          ),

          // Nhanh 3: Garden
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/garden',
                name: 'garden',
                builder: (context, state) => const GardenScreen(),
              ),
            ],
          ),

          // Nhanh 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // === CAC MAN HINH DOC LAP (Khong co Bottom Navigation Bar) ===
      // History cua Chan doan
      GoRoute(
        path: '/diagnosis/history',
        name: 'diagnosis-history',
        builder: (context, state) => const DiagnosisHistoryScreen(),
      ),

      // === ADMIN (Web) ===
      GoRoute(
        path: '/admin',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // === SETTINGS ===
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // TIPS (Chua phan nhanh hoac la man hinh doc lap)
      GoRoute(
        path: '/tips',
        name: 'tips',
        builder: (context, state) => const _ComingSoon(title: 'Meo hay'),
      ),
    ],
  );
});

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('$title\nDang phat trien...', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Quay ve Trang chu'),
            ),
          ],
        ),
      ),
    );
  }
}
