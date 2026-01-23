import 'package:imart/features/profile/application/states/profile_state.dart';
import 'package:imart/features/profile/domain/repositories/profile_repository.dart';
import 'package:imart/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

/// Profile Notifier for managing user profile state
@Riverpod(keepAlive: true)
class Profile extends _$Profile {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileState build() {
    // Initialize by loading cached profile
    _loadProfile();
    return const ProfileInitial();
  }

  /// Load profile (cache-first strategy)
  Future<void> _loadProfile() async {
    try {
      state = const ProfileLoading();

      final result = await _repository.getProfile();

      result.fold(
        (failure) {
          state = ProfileError(failure, state);
        },
        (user) {
          state = ProfileLoaded(user);
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Refresh profile (force fetch from API)
  Future<void> refreshProfile() async {
    try {
      state = const ProfileLoading();

      final result = await _repository.getProfile(forceRefresh: true);

      result.fold(
        (failure) {
          state = ProfileError(failure, state);
        },
        (user) {
          state = ProfileLoaded(user);
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Update profile information
  Future<void> updateProfile({
    required String firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      // Get current user for optimistic update
      final currentState = state;
      if (currentState is ProfileLoaded) {
        state = ProfileUpdating(currentState.user);
      } else {
        state = const ProfileLoading();
      }

      final result = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      result.fold(
        (failure) {
          state = ProfileError(failure, currentState);
        },
        (user) {
          state = ProfileUpdated(user);
          // Transition to loaded state after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            state = ProfileLoaded(user);
          });
        },
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Clear profile cache and reload
  Future<void> clearAndReload() async {
    await _repository.clearCache();
    await _loadProfile();
  }
}
