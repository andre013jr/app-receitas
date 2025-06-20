// lib/bloc/auth_bloc.dart (VERSÃO ATUALIZADA)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data_provider/auth_data_provider.dart';

// --- Eventos ---
abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;
  RegisterEvent({required this.email, required this.password, required this.username});
}

// 1. ADICIONAR NOVO EVENTO DE LOGIN
class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}
// ... outros eventos como LogoutEvent no futuro

// --- Estados (continuam os mesmos) ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthDataProvider authDataProvider;

  AuthBloc({required this.authDataProvider}) : super(AuthInitial()) {
    // Handler para o evento de Registro
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await authDataProvider.registerWithEmail(
          event.email,
          event.password,
          event.username,
        );
        emit(Authenticated(userCredential.user!));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'A senha fornecida é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Já existe uma conta com este e-mail.';
        } else {
          message = e.message ?? "Erro desconhecido ao registrar.";
        }
        emit(AuthError(message));
      }
    });

    // 2. ADICIONAR NOVO HANDLER PARA O EVENTO DE LOGIN
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await authDataProvider.loginWithEmail(event.email, event.password);
        emit(Authenticated(userCredential.user!));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            message = 'E-mail ou senha incorretos.';
        } else if (e.code == 'wrong-password') {
            message = 'Senha incorreta para este e-mail.';
        } else {
            message = 'Erro de login: ${e.message}';
        }
        emit(AuthError(message));
      }
    });
  }
}