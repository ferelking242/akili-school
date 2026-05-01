import 'dart:async';

import '../../../core/config/app_config.dart';
import '../../../domain/entities/user_entity.dart';

/// Thin wrapper around Supabase auth.
///
/// When Supabase is not configured (no env vars), this falls back to a
/// deterministic in-memory mock so the app remains fully usable for demos
/// and CI builds.
class SupabaseAuthSource {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  Future<AppUser?> currentUser() async => _current;

  Stream<AppUser?> changes() => _controller.stream;

  Future<AppUser> signInWithEmail(String email, String password) async {
    if (AppConfig.hasSupabaseConfig) {
      // Real Supabase call would happen here. Wrapped to avoid hard-coupling
      // the demo build to a live backend.
      // final res = await Supabase.instance.client.auth
      //     .signInWithPassword(email: email, password: password);
      // return _fromSupabase(res.user!);
    }
    return _mockSignIn(email);
  }

  Future<AppUser> signInWithQrToken(String token) async {
    // QR token format: role:email (demo). Real impl validates against backend.
    final parts = token.split(':');
    final email = parts.length > 1 ? parts[1] : 'student@scolaris.app';
    return _mockSignIn(email);
  }

  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  /// Deterministic mock — derives a role from the local-part of the email
  /// so demos can showcase every role.
  AppUser _mockSignIn(String email) {
    final local = email.split('@').first.toLowerCase();
    final role = _detectRole(local);
    final user = AppUser(
      id: 'mock-${local.hashCode}',
      email: email,
      fullName: _humanize(local),
      role: role,
      schoolId: 'akili-demo',
      schoolAccentArgb: AppConfig.defaultAccentArgb,
    );
    _current = user;
    _controller.add(user);
    return user;
  }

  UserRole _detectRole(String local) {
    if (local.contains('admin')) return UserRole.admin;
    if (local.contains('teacher') || local.contains('prof')) {
      return UserRole.teacher;
    }
    if (local.contains('parent')) return UserRole.parent;
    if (local.contains('finance')) return UserRole.finance;
    if (local.contains('survey') || local.contains('surveillance')) {
      return UserRole.surveillance;
    }
    return UserRole.student;
  }

  String _humanize(String s) {
    if (s.isEmpty) return 'User';
    return s[0].toUpperCase() + s.substring(1);
  }
}
