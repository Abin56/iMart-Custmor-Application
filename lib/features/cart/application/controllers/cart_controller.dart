import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/checkout_line.dart';
import '../../infrastructure/data_sources/checkout_line_remote_data_source.dart';
import '../providers/cart_providers.dart';
import '../states/cart_state.dart';

part 'cart_controller.g.dart';

/// Cart controller with debouncing for quantity updates
@riverpod
class CartController extends _$CartController {
  Timer? _debounceTimer;
  Timer? _pollingTimer;

  // Debounce delay for quantity updates (150ms as per backend docs)
  static const _debounceDuration = Duration(milliseconds: 150);

  // Polling interval for HTTP 304 (30s as per backend docs)
  static const _pollingInterval = Duration(seconds: 30);

  @override
  CartState build() {
    // Load cart immediately when controller is first created
    Future.microtask(loadCart);

    // Start polling when controller is first created
    _startPolling();

    // Cancel timers when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _pollingTimer?.cancel();
    });

    return CartState.initial();
  }

  /// Start polling for cart updates using HTTP 304
  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (state.status != CartStatus.loading) {
        _refreshCart(silent: true);
      }
    });
  }

  /// Load cart items (initial load or force refresh)
  Future<void> loadCart({bool forceRefresh = false}) async {
    state = state.copyWith(status: CartStatus.loading, errorMessage: null);

    try {
      final repository = await ref.read(checkoutLineRepositoryProvider.future);
      final response = await repository.getCheckoutLines(
        forceRefresh: forceRefresh,
      );

      // If response is null, data hasn't changed (HTTP 304)
      if (response == null) {
        state = state.copyWith(status: CartStatus.loaded);
        return;
      }

      state = state.copyWith(
        status: CartStatus.loaded,
        data: response,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Silent refresh (for polling) - doesn't change loading state
  Future<void> _refreshCart({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isRefreshing: true);
    }

    try {
      final repository = await ref.read(checkoutLineRepositoryProvider.future);
      final response = await repository.getCheckoutLines();

      // If response is null, data hasn't changed (HTTP 304)
      if (response != null) {
        state = state.copyWith(
          status: CartStatus.loaded,
          data: response,
          errorMessage: null,
          isRefreshing: false,
        );
      } else if (!silent) {
        state = state.copyWith(isRefreshing: false);
      }
    } catch (e) {
      if (!silent) {
        state = state.copyWith(isRefreshing: false, errorMessage: e.toString());
      }
    }
  }

  /// Add item to cart
  Future<void> addToCart({
    required int productVariantId,
    required int quantity,
  }) async {
    try {
      final repository = await ref.read(checkoutLineRepositoryProvider.future);
      await repository.addToCart(
        productVariantId: productVariantId,
        quantity: quantity,
      );

      // Refresh cart after adding
      await loadCart(forceRefresh: true);
    } catch (e) {
      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Update quantity with debouncing (150ms delay)
  ///
  /// IMPORTANT: [quantityDelta] is the change amount, not absolute value
  /// - Positive: increment (e.g., +1, +2)
  /// - Negative: decrement (e.g., -1, -2)
  ///
  /// Uses optimistic updates for instant UI feedback
  void updateQuantity({
    required int lineId,
    required int productVariantId,
    required int quantityDelta,
  }) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Optimistic update - immediately update UI
    final currentData = state.data;
    if (currentData != null) {
      final updatedLines = currentData.results.map((line) {
        if (line.id == lineId) {
          final newQuantity = line.quantity + quantityDelta;
          // Don't allow quantity to go below 1
          if (newQuantity < 1) return line;
          return line.copyWith(quantity: newQuantity);
        }
        return line;
      }).toList();

      state = state.copyWith(data: currentData.copyWith(results: updatedLines));
    }

    // Debounce the actual API call
    _debounceTimer = Timer(_debounceDuration, () {
      _executeQuantityUpdate(
        lineId: lineId,
        productVariantId: productVariantId,
        quantityDelta: quantityDelta,
      );
    });
  }

  /// Execute the actual quantity update API call
  Future<void> _executeQuantityUpdate({
    required int lineId,
    required int productVariantId,
    required int quantityDelta,
  }) async {
    try {
      final repository = await ref.read(checkoutLineRepositoryProvider.future);
      await repository.updateQuantity(
        lineId: lineId,
        productVariantId: productVariantId,
        quantity: quantityDelta, // This is a delta!
      );

      // Refresh cart after update
      await loadCart(forceRefresh: true);
    } on ItemRemovedFromCartException {
      // Item was removed from cart (quantity reached 0)
      // This is a success case - just refresh the cart
      await loadCart(forceRefresh: true);
      // Don't set error state or rethrow - this is expected behavior
    } catch (e) {
      // Check if it's a 404 error (cart item not found)
      if (e.toString().contains('Cart item not found') ||
          e.toString().contains('404')) {
        // Force refresh to sync with backend state
        await loadCart(forceRefresh: true);
        // Don't show error to user - just silently sync
        return;
      }

      // For other errors, rollback optimistic update
      await loadCart(forceRefresh: true);

      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete item from cart
  Future<void> deleteItem(int lineId) async {
    // Optimistic update - immediately remove from UI
    final currentData = state.data;
    if (currentData != null) {
      final updatedLines = currentData.results
          .where((line) => line.id != lineId)
          .toList();

      state = state.copyWith(data: currentData.copyWith(results: updatedLines));
    }

    try {
      final repository = await ref.read(checkoutLineRepositoryProvider.future);
      await repository.deleteCheckoutLine(lineId);

      // Refresh cart after delete
      await loadCart(forceRefresh: true);
    } catch (e) {
      // Rollback optimistic update on error
      await loadCart(forceRefresh: true);

      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Get a specific cart line by ID
  CheckoutLine? getLineById(int lineId) {
    return state.data?.results.firstWhere(
      (line) => line.id == lineId,
      orElse: () => throw Exception('Line not found'),
    );
  }

  /// Clear cart state locally (used after successful payment)
  void clearCart() {
    state = CartState.initial();
  }
}
