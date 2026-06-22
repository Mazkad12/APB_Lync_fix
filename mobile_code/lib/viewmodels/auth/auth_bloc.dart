import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/history_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final HistoryRepository historyRepository;

  AuthBloc({required this.authRepository, required this.historyRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Check if user is already logged in via Firebase
       await for(final user in authRepository.user.take(1)){
          if(user != null){
             await user.reload();
             final freshUser = authRepository.currentUser;
             if (freshUser != null) {
               await _checkAndPerformMigration(freshUser);
               emit(Authenticated(freshUser));
               return;
             }
          }
       }
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signIn(
          email: event.email, password: event.password);
      if (user != null) {
        await _checkAndPerformMigration(user);
        emit(Authenticated(user));
      } else {
        emit(const AuthError("Login failed"));
      }
    } catch (e) {
      emit(AuthError(_getCleanErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
      RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUp(
          email: event.email, password: event.password, name: event.name);
      if (user != null) {
        // Here you might want to save the user's name to Firestore
        emit(RegistrationSuccess());
      } else {
        emit(const AuthError("Registration failed"));
      }
    } catch (e) {
      emit(AuthError(_getCleanErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(_getCleanErrorMessage(e)));
    }
  }

  void _onGuestLoginRequested(
      GuestLoginRequested event, Emitter<AuthState> emit) {
    emit(GuestMode());
  }

  Future<void> _onForgotPasswordRequested(
      ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordReset(email: event.email);
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(AuthError(_getCleanErrorMessage(e)));
    }
  }

  Future<void> _onUpdateProfileRequested(
      UpdateProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final currentUser = authRepository.currentUser;
      if (currentUser != null) {
        final oldEmail = currentUser.email;
        final newEmail = event.email;

        // 1. Update Firebase Auth Profile Name
        if (currentUser.displayName != event.displayName) {
          await currentUser.updateDisplayName(event.displayName);
        }

        // 2. Verify new email before updating if changed
        if (oldEmail != newEmail) {
          await currentUser.verifyBeforeUpdateEmail(newEmail);

          // 3. Save pending migration details to Firestore
          await FirebaseFirestore.instance
              .collection('pending_migrations')
              .doc(currentUser.uid)
              .set({
                'oldEmail': oldEmail,
                'newEmail': newEmail,
              });
        }

        // Reload user to get fresh data
        await currentUser.reload();
        final updatedUser = authRepository.currentUser;
        if (updatedUser != null) {
          emit(Authenticated(updatedUser));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(_getCleanErrorMessage(e)));
      // Re-emit Authenticated state with existing user if error occurs
      final user = authRepository.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      }
    }
  }

  Future<void> _checkAndPerformMigration(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('pending_migrations')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        final oldEmail = data?['oldEmail'] as String?;
        final newEmail = data?['newEmail'] as String?;
        if (oldEmail != null && newEmail != null && user.email == newEmail) {
          await historyRepository.migrateHistory(oldEmail, newEmail);
          await doc.reference.delete();
        }
      }
    } catch (e) {
      print("Pending migration check failed: $e");
    }
  }

  String _getCleanErrorMessage(dynamic e) {
    return e.toString().replaceFirst('Exception: ', '');
  }
}
