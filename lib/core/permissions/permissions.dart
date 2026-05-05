import '../../domain/entities/user_entity.dart';

/// Centralized RBAC. UI must NEVER hardcode role checks — call this service.
///
/// Example:
///   if (PermissionService.I.canEditGrades(user)) { ... }
class PermissionService {
  PermissionService._();
  static final I = PermissionService._();

  bool canViewDashboard(AppUser? u) => u != null;

  bool canEditGrades(AppUser? u) =>
      u != null && (u.role == UserRole.teacher || u.role == UserRole.staff);

  bool canMarkAttendance(AppUser? u) =>
      u != null &&
      (u.role == UserRole.teacher ||
          u.role == UserRole.staff);

  bool canManagePayments(AppUser? u) =>
      u != null && u.role == UserRole.staff;

  bool canManageUsers(AppUser? u) => u != null && u.role == UserRole.staff;

  bool canViewChildren(AppUser? u) => u?.role == UserRole.parent;

  bool canScanQr(AppUser? u) =>
      u != null &&
      (u.role == UserRole.staff ||
          u.role == UserRole.teacher);
}
