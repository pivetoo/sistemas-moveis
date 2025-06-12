import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/login_credentials.dart';
import '../../repository/auth_repository.dart';
import 'auth_event.dart';
import '../../models/usuario.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final isAuthenticated = await _authRepository.isAuthenticated();

      if (isAuthenticated) {
        emit(const AuthAuthenticated(
          usuario: Usuario(
            id: 0,
            nome: 'Usuário',
            login: '',
            tipoUsuario: '',
          ),
          token: '',
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final credentials = LoginCredentials(
        login: event.login,
        senha: event.senha,
      );

      final response = await _authRepository.login(credentials);

      emit(AuthAuthenticated(
        usuario: response.usuario ?? const Usuario(
          id: 0,
          nome: 'Usuário',
          login: '',
          tipoUsuario: '',
        ),
        token: response.token,
      ));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}