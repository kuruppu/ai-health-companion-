import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/auth_status.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_with_email_usecase.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  late final LoginWithEmailUseCase _loginUseCase;
  late final RegisterWithEmailUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  @override
  Future<AuthStatus> build() async {
    _loginUseCase = getIt<LoginWithEmailUseCase>();
    _registerUseCase = getIt<RegisterWithEmailUseCase>();
    _logoutUseCase = getIt<LogoutUseCase>();
    _getCurrentUserUseCase = getIt<GetCurrentUserUseCase>();

    final result = await _getCurrentUserUseCase();

    return result.fold(
      (failure) => const Unauthenticated(),
      (user) => user != null ? Authenticated(user) : const Unauthenticated(),
    );
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _loginUseCase(
      email: email,
      password: password,
    );

    state = result.fold(
      (failure) => AsyncValue.data(AuthError(failure.message)),
      (user) => AsyncValue.data(Authenticated(user)),
    );
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();

    final result = await _registerUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );

    state = result.fold(
      (failure) => AsyncValue.data(AuthError(failure.message)),
      (user) => AsyncValue.data(Authenticated(user)),
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    final result = await _logoutUseCase();

    state = result.fold(
      (failure) => AsyncValue.data(AuthError(failure.message)),
      (user) => const AsyncValue.data(Unauthenticated()),
    );
  }

  User? getCurrentUser() {
    return state.value is Authenticated
        ? (state.value as Authenticated).user
        : null;
  }
}
