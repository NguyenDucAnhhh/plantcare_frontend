import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/admin/screens/admin_login_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/change_password_screen.dart';
import '../../features/diagnosis/screens/diagnosis_screen.dart';
import '../../features/diagnosis/screens/diagnosis_history_screen.dart';
import '../../features/garden/screens/garden_screen.dart';
import '../../features/post/screens/post_screen.dart';
import '../../features/post/screens/post_detail_screen.dart';
import '../../features/post/screens/community_search_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../../features/admin/screens/admin_tips_screen.dart';
import '../../features/admin/screens/admin_tip_editor_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_posts_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/admin_diagnoses_screen.dart';
import '../../features/admin/widgets/admin_layout_shell.dart';
import '../../features/tips/screens/tips_screen.dart';
import '../../features/tips/screens/tip_detail_screen.dart';
import '../../features/tips/data/care_tip_model.dart';
import '../widgets/scaffold_with_nav_bar.dart';
import '../../core/storage/secure_storage.dart';

/// GoRouter SINGLETON - chi tao 1 lan duy nhat, KHONG bi recreate
/// Su dung async redirect thay vi watch Provider de tranh reset ve initialLocation
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: false,

    // redirect co the la async (FutureOr<String?>) - GoRouter ho tro
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      // === ADMIN ROUTES: HOAN TOAN BYPASS - khong ap dung bat ky rule nao ===
      if (loc.startsWith('/admin')) return null;

      // === USER ROUTES: Kiem tra JWT Token ===
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final isAuthRoute = loc == '/login' || 
                          loc == '/register' || 
                          loc == '/forgot-password' || 
                          loc == '/otp-verification' || 
                          loc == '/reset-password';

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
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp_verification',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final email = extra['email'] as String? ?? '';
          final otp = extra['otp'] as String? ?? '';
          return ResetPasswordScreen(email: email, otp: otp);
        },
      ),
      
      // === POST DETAIL ===
      GoRoute(
        path: '/post/:id',
        name: 'post_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),

      GoRoute(
        path: '/user/:id',
        name: 'public_profile',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PublicProfileScreen(userId: id);
        },
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
                builder: (context, state) => const PostScreen(),
              ),
              GoRoute(
                path: '/posts/:id',
                builder: (context, state) => PostDetailScreen(
                  postId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: '/community-search',
                builder: (context, state) => const CommunitySearchScreen(),
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
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminLayoutShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                builder: (context, state) => const AdminUsersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/posts',
                builder: (context, state) => const AdminPostsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/reports',
                builder: (context, state) => const AdminReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/tips',
                builder: (context, state) => const AdminTipsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/diagnoses',
                builder: (context, state) => const AdminDiagnosesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/admin/tips/edit',
        builder: (context, state) {
          final tip = state.extra as CareTipModel?;
          return AdminTipEditorScreen(initialTip: tip);
        },
      ),

      // === SETTINGS ===
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change_password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      // === TIPS ===
      GoRoute(
        path: '/tips',
        name: 'tips',
        builder: (context, state) => const TipsScreen(),
      ),
      GoRoute(
        path: '/tips/detail',
        name: 'tip_detail',
        builder: (context, state) {
          final tip = state.extra as CareTipModel;
          return TipDetailScreen(tip: tip);
        },
      ),
    ],
  );
});
