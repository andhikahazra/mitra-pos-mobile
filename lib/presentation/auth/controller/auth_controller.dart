import 'package:injectable/injectable.dart';
import 'package:mitrapos/core/di/injection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitrapos/domain/auth/entities/auth_user.dart';
import 'package:mitrapos/domain/auth/usecases/login_usecase.dart';
import 'package:mitrapos/domain/auth/usecases/get_profile_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => getIt<AuthController>(),
);

@injectable
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final GetProfileUseCase getProfileUseCase;

  AuthController({
    required this.loginUseCase,
    required this.getProfileUseCase,
  }) : super(const AuthState());

  Future<void> add(AuthEvent event) async {
    if (event is LoginSubmitted) {
      await _onLoginSubmitted(event);
      return;
    }

    if (event is AuthErrorCleared) {
      _onErrorCleared(event);
      return;
    }

    if (event is LogoutRequested) {
      await _onLogoutRequested();
      return;
    }

    if (event is GetProfileRequested) {
      await _onGetProfileRequested();
    }
  }

  Future<void> _onGetProfileRequested() async {
    if (state.user != null) return; // Already fetched, skip
    final result = await getProfileUseCase();
    result.fold(
      (failure) => null, // Silently fail if can't get profile (e.g. not logged in)
      (user) => state = state.copyWith(user: user, isAuthenticated: true),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isAuthenticated: false);

    final result = await loginUseCase(email: event.email, password: event.password);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (user) => state =
        state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          errorMessage: null,
        ),
    );
  }

  void _onErrorCleared(
    AuthErrorCleared event,
  ) {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> _onLogoutRequested() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.remove('auth_token');
    state = const AuthState();
  }
}
