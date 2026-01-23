import 'package:imart/app/core/error/failure.dart';
import 'package:imart/features/auth/domain/entities/user.dart';

/// Sealed class for type-safe profile state management
sealed class ProfileState {
  const ProfileState();
}

/// Initial state - checking for cached profile
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state - fetching profile from API
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);

  final UserEntity user;
}

/// Updating profile (for update operations)
class ProfileUpdating extends ProfileState {
  const ProfileUpdating(this.currentUser);

  final UserEntity currentUser;
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  const ProfileUpdated(this.user);

  final UserEntity user;
}

/// Error state with previous state for recovery
class ProfileError extends ProfileState {
  const ProfileError(this.failure, this.previousState);

  final Failure failure;
  final ProfileState previousState;
}
