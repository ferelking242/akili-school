import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/sources/remote/supabase_auth_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';

final supabaseAuthSourceProvider =
    Provider<SupabaseAuthSource>((ref) => SupabaseAuthSource());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(supabaseAuthSourceProvider)),
);

final signInUseCaseProvider =
    Provider((ref) => SignInUseCase(ref.watch(authRepositoryProvider)));
final signOutUseCaseProvider =
    Provider((ref) => SignOutUseCase(ref.watch(authRepositoryProvider)));
final signInWithQrUseCaseProvider =
    Provider((ref) => SignInWithQrUseCase(ref.watch(authRepositoryProvider)));

/// Stream of the currently authenticated user (or null).
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authChanges();
});

/// Synchronous accessor — useful in router redirect.
class AuthSession extends StateNotifier<AppUser?> {
  AuthSession(this._ref) : super(null) {
    _ref.listen<AsyncValue<AppUser?>>(authStateProvider, (_, next) {
      next.whenData((u) => state = u);
    });
  }
  final Ref _ref;
}

final authSessionProvider =
    StateNotifierProvider<AuthSession, AppUser?>((ref) => AuthSession(ref));
