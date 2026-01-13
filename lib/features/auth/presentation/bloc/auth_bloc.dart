import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:khel_mitra/features/auth/domain/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class RequestOtp extends AuthEvent {
  final String phoneNumber;
  RequestOtp(this.phoneNumber);
  
  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtp extends AuthEvent {
  final String verificationId;
  final String otp;
  VerifyOtp(this.verificationId, this.otp);
  
  @override
  List<Object?> get props => [verificationId, otp];
}

class OtpSent extends AuthEvent {
  final String phoneNumber;
  final String verificationId;
  OtpSent(this.phoneNumber, this.verificationId);
  
  @override
  List<Object?> get props => [phoneNumber, verificationId];
}

class OtpError extends AuthEvent {
  final String message;
  OtpError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class AutoVerified extends AuthEvent {}

class Logout extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class CodeSent extends AuthState {
  final String phoneNumber;
  final String verificationId;
  
  CodeSent(this.phoneNumber, this.verificationId);
  
  @override
  List<Object?> get props => [phoneNumber, verificationId];
}

class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final String? phoneNumber;
  final String? verificationId;
  
  AuthError(this.message, {this.phoneNumber, this.verificationId});
  
  @override
  List<Object?> get props => [message, phoneNumber, verificationId];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RequestOtp>(_onRequestOtp);
    on<OtpSent>(_onOtpSent);
    on<OtpError>(_onOtpError);
    on<AutoVerified>(_onAutoVerified);
    on<VerifyOtp>(_onVerifyOtp);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRequestOtp(
    RequestOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    await _authRepository.requestOtp(
      event.phoneNumber,
      onCodeSent: (verificationId) {
        add(OtpSent(event.phoneNumber, verificationId));
      },
      onError: (error) {
        add(OtpError(error));
      },
      onAutoVerified: () {
        add(AutoVerified());
      },
    );
  }

  void _onOtpSent(
    OtpSent event,
    Emitter<AuthState> emit,
  ) {
    emit(CodeSent(event.phoneNumber, event.verificationId));
  }

  void _onOtpError(
    OtpError event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthError(event.message));
    emit(AuthUnauthenticated());
  }

  void _onAutoVerified(
    AutoVerified event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthAuthenticated());
  }

  Future<void> _onVerifyOtp(
    VerifyOtp event,
    Emitter<AuthState> emit,
  ) async {
    // Get current state to preserve phone number for error recovery
    final currentState = state;
    String? phoneNumber;
    if (currentState is CodeSent) {
      phoneNumber = currentState.phoneNumber;
    }
    
    emit(AuthLoading());
    
    try {
      final success = await _authRepository.verifyOtp(
        event.verificationId,
        event.otp,
      );
      
      if (success) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthError(
          'Invalid OTP. Please try again.',
          phoneNumber: phoneNumber,
          verificationId: event.verificationId,
        ));
        // Return to CodeSent state so user can retry
        if (phoneNumber != null) {
          emit(CodeSent(phoneNumber, event.verificationId));
        }
      }
    } catch (e) {
      emit(AuthError(
        'Verification failed. Please try again.',
        phoneNumber: phoneNumber,
        verificationId: event.verificationId,
      ));
      if (phoneNumber != null) {
        emit(CodeSent(phoneNumber, event.verificationId));
      }
    }
  }

  Future<void> _onLogout(
    Logout event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}
