import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/core/network/api_client.dart';
import '../../domain/entities/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../infrastructure/data_sources/wishlist_local_data_source.dart';
import '../../infrastructure/data_sources/wishlist_remote_data_source.dart';
import '../../infrastructure/repositories/wishlist_repository_impl.dart';
import '../states/wishlist_state.dart';

part 'wishlist_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

/// Wishlist remote data source provider
@riverpod
WishlistRemoteDataSource wishlistRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WishlistRemoteDataSourceImpl(apiClient);
}

/// Wishlist local data source provider
@riverpod
WishlistLocalDataSource wishlistLocalDataSource(Ref ref) {
  return WishlistLocalDataSourceImpl();
}

// ============================================================================
// Repository
// ============================================================================

/// Wishlist repository provider
@riverpod
WishlistRepository wishlistRepository(Ref ref) {
  final remoteDataSource = ref.watch(wishlistRemoteDataSourceProvider);
  final localDataSource = ref.watch(wishlistLocalDataSourceProvider);

  return WishlistRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}

// ============================================================================
// State Notifier
// ============================================================================

/// Wishlist state notifier
@Riverpod(keepAlive: true)
class Wishlist extends _$Wishlist {
  WishlistRepository get _repository => ref.read(wishlistRepositoryProvider);

  @override
  WishlistState build() {
    // Auto-load wishlist on initialization
    Future.microtask(_loadWishlist);
    return const WishlistState.initial();
  }

  /// Load wishlist from repository
  Future<void> _loadWishlist() async {
    // Don't overwrite refreshing state with loading
    state.maybeMap(
      refreshing: (_) {},
      orElse: () => state = const WishlistState.loading(),
    );

    final result = await _repository.getWishlist();

    result.fold(
      (failure) {
        state = WishlistState.error(failure: failure, previousState: state);
      },
      (items) {
        state = WishlistState.loaded(items: items);
      },
    );
  }

  /// Refresh (pull-to-refresh)
  Future<void> refresh() async {
    // Clear cache to force fresh data from API
    await _repository.clearCache();

    // Refresh regardless of current state
    await state.maybeMap(
      loaded: (loadedState) async {
        state = WishlistState.refreshing(items: loadedState.items);
        await _loadWishlist();
      },
      error: (_) async {
        await _loadWishlist();
      },
      orElse: () async {
        // Handle initial, loading, or refreshing states
        await _loadWishlist();
      },
    );
  }

  /// Add to wishlist
  Future<bool> addToWishlist(String productId) async {
    // Prevent duplicates
    if (isInWishlist(productId)) {
      return false;
    }

    final result = await _repository.addToWishlist(productId);

    return result.fold(
      (failure) {
        state.mapOrNull(
          loaded: (loadedState) {
            state = WishlistState.error(
              failure: failure,
              previousState: loadedState,
            );
          },
        );

        return false;
      },
      (item) {
        // Optimistic update: add item to list immediately
        final currentState = state;
        if (currentState is WishlistLoaded) {
          final updatedItems = [...currentState.items, item];
          state = WishlistState.loaded(items: updatedItems);
        } else {
          // If not loaded yet, trigger full load
          _loadWishlist();
        }

        return true;
      },
    );
  }

  /// Remove from wishlist (by wishlist item ID)
  Future<bool> removeFromWishlist(String wishlistItemId) async {
    // Optimistic update: remove item from list immediately
    final currentState = state;
    if (currentState is WishlistLoaded) {
      final updatedItems = currentState.items
          .where((item) => item.id.toString() != wishlistItemId)
          .toList();
      state = WishlistState.loaded(items: updatedItems);
    }

    final result = await _repository.removeFromWishlist(wishlistItemId);

    return result.fold(
      (failure) {
        // Revert optimistic update on failure
        if (currentState is WishlistLoaded) {
          state = currentState;
        }

        state.mapOrNull(
          loaded: (loadedState) {
            state = WishlistState.error(
              failure: failure,
              previousState: loadedState,
            );
          },
        );

        return false;
      },
      (_) {
        // Success - item already removed from UI via optimistic update
        // No need to reload entire list
        return true;
      },
    );
  }

  /// Remove by product ID (user-friendly)
  Future<bool> removeFromWishlistByProductId(String productId) async {
    // Optimistic update: remove item from list immediately
    final currentState = state;
    if (currentState is WishlistLoaded) {
      final updatedItems = currentState.items
          .where((item) => item.productId != productId)
          .toList();
      state = WishlistState.loaded(items: updatedItems);
    }

    final result = await _repository.removeFromWishlistByProductId(productId);

    return result.fold(
      (failure) {
        // Revert optimistic update on failure
        if (currentState is WishlistLoaded) {
          state = currentState;
        }
        return false;
      },
      (_) {
        // Success - item already removed from UI via optimistic update
        return true;
      },
    );
  }

  /// Toggle wishlist (add if not present, remove if present)
  Future<bool> toggleWishlist(String productId) async {
    return isInWishlist(productId)
        ? removeFromWishlistByProductId(productId)
        : addToWishlist(productId);
  }

  /// Check if product is in wishlist
  bool isInWishlist(String productId) {
    return state.isInWishlist(productId);
  }

  /// Clear error
  void clearError() {
    state.mapOrNull(
      error: (errorState) {
        if (errorState.previousState != null) {
          state = errorState.previousState!;
        } else {
          state = const WishlistState.initial();
        }
      },
    );
  }
}

// ============================================================================
// Helper Providers
// ============================================================================

/// Watch only items (optimization)
@riverpod
List<WishlistItem> wishlistItems(Ref ref) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.items;
}

/// Check if specific product is in wishlist
@riverpod
bool isInWishlist(Ref ref, String productId) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.isInWishlist(productId);
}

/// Get wishlist count
@riverpod
int wishlistCount(Ref ref) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.itemCount;
}
