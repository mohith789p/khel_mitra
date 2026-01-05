import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}
class RequestOtp extends AuthEvent {
  final String phoneNumber;
  RequestOtp(this.phoneNumber);
}
class VerifyOtp extends AuthEvent {
  final String phoneNumber;
  final String otp;
  VerifyOtp(this.phoneNumber, this.otp);
}
class Logout extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class CodeSent extends AuthState {
  final String phoneNumber;
  CodeSent(this.phoneNumber);
  @override
  List<Object> get props => [phoneNumber];
}
class AuthAuthenticated extends AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<RequestOtp>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.requestOtp(event.phoneNumber);
        emit(CodeSent(event.phoneNumber));
      } catch (e) {
        emit(AuthError("Failed to send OTP"));
      }
    });

    on<VerifyOtp>((event, emit) async {
      emit(AuthLoading());
      try {
        final success = await _authRepository.verifyOtp(event.phoneNumber, event.otp);
        if (success) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthError("Invalid OTP"));
          emit(CodeSent(event.phoneNumber)); // Go back to OTP screen
        }
      } catch (e) {
        emit(AuthError("Verification failed"));
        emit(CodeSent(event.phoneNumber));
      }
    });

    on<Logout>((event, emit) async {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    });
  }
}
