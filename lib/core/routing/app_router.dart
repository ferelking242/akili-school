import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user_entity.dart';
import '../../features/admin/presentation/admin_home.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/finance/presentation/finance_home.dart';
import '../../features/parent/presentation/parent_home.dart';
import '../../features/student/presentation/student_home.dart';
import '../../features/surveillance/presentation/surveillance_home.dart';
import '../../features/teacher/presentation/teacher_home.dart';
import '../../presentation/providers/auth_providers.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const student = '/student';
  static const parent = '/parent';
  static const teacher = '/teacher';
  static const surveillance = '/surveillance';
  static const finance = '/finance';
  static const admin = '/admin';
}

String roleHome(UserRole role) {
  switch (role) {
    case UserRole.student:
      return AppRoutes.student;
    case UserRole.parent:
      return AppRoutes.parent;
    case UserRole.teacher:
      return AppRoutes.teacher;
    case UserRole.surveillance:
      return AppRoutes.surveillance;
    case UserRole.finance:
      return AppRoutes.finance;
    case UserRole.admin:
      return AppRoutes.admin;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (ctx, state) {
      final user = ref.read(authSessionProvider);
      final loc = state.matchedLocation;
      final atSplash = loc == AppRoutes.splash;
      final atLogin = loc == AppRoutes.login;

      if (user == null) {
        // Not logged in → must be at login (splash bounces to login).
        if (atLogin) return null;
        return AppRoutes.login;
      }

      // Logged in → not allowed back to login/splash.
      if (atLogin || atSplash) return roleHome(user.role);

      // Enforce role-bounded subtrees.
      final home = roleHome(user.role);
      if (!loc.startsWith(home)) return home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.student,
        builder: (_, __) => const StudentHome(),
      ),
      GoRoute(path: AppRoutes.parent, builder: (_, __) => const ParentHome()),
      GoRoute(path: AppRoutes.teacher, builder: (_, __) => const TeacherHome()),
      GoRoute(
        path: AppRoutes.surveillance,
        builder: (_, __) => const SurveillanceHome(),
      ),
      GoRoute(path: AppRoutes.finance, builder: (_, __) => const FinanceHome()),
      GoRoute(path: AppRoutes.admin, builder: (_, __) => const AdminHome()),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authSessionProvider, (_, __) => notifyListeners());
  }
}
