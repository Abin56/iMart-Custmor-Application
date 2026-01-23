import 'package:imart/app/core/error/failure.dart';

import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthChecking extends AuthState {
  const AuthChecking();
}

/// Initial State
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Guest Mode (Browsing without authentication)
class GuestMode extends AuthState {
  const GuestMode();
}

/// Loading (Login, Signup, Generic loading)
class AuthLoading extends AuthState {
  const AuthLoading({this.message = 'Loading...'});
  final String message;
}

/// OTP Sending
class OtpSending extends AuthState {
  const OtpSending(this.mobileNumber);
  final String mobileNumber;
}

/// OTP Sent
class OtpSent extends AuthState {
  const OtpSent({
    required this.mobileNumber,
    required this.isSuccess,
    required this.expiresInSeconds,
  });
  final String mobileNumber;
  final bool isSuccess;
  final int expiresInSeconds;
}

/// OTP Verifying
class OtpVerifying extends AuthState {
  const OtpVerifying(this.mobileNumber);
  final String mobileNumber;
}

/// Authenticated
class Authenticated extends AuthState {
  const Authenticated({required this.user, required this.isNewUser});
  final UserEntity user;
  final bool isNewUser;
}

/// Auth Error
class AuthError extends AuthState {
  const AuthError({required this.failure, required this.previousState});
  final Failure failure;
  final AuthState previousState;
}
