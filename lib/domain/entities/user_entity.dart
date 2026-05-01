/// Application roles. Single source of truth.
enum UserRole {
  student,
  parent,
  teacher,
  surveillance,
  finance,
  admin;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.student,
    );
  }
}

/// Authenticated user entity (domain layer — pure Dart, no framework deps).
class AppUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? schoolId;
  final String? avatarUrl;
  final int? schoolAccentArgb;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.schoolId,
    this.avatarUrl,
    this.schoolAccentArgb,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? schoolId,
    String? avatarUrl,
    int? schoolAccentArgb,
  }) =>
      AppUser(
        id: id ?? this.id,
        email: email ?? this.email,
        fullName: fullName ?? this.fullName,
        role: role ?? this.role,
        schoolId: schoolId ?? this.schoolId,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        schoolAccentArgb: schoolAccentArgb ?? this.schoolAccentArgb,
      );
}
