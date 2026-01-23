import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/checkout_lines_response.dart';

part 'cart_state.freezed.dart';

/// Cart state with status and data
@freezed
class CartState with _$CartState {
  const factory CartState({
    required CartStatus status,
    CheckoutLinesResponse? data,
    String? errorMessage,
    @Default(false) bool isRefreshing,
  }) = _CartState;

  const CartState._();

  /// Initial state
  factory CartState.initial() => const CartState(status: CartStatus.initial);

  /// Check if cart is empty
  bool get isEmpty => data?.isEmpty ?? true;

  /// Check if cart has items
  bool get isNotEmpty => data?.isNotEmpty ?? false;

  /// Get total items count
  int get totalItems => data?.totalItems ?? 0;

  /// Get total amount
  double get totalAmount => data?.totalAmount ?? 0.0;

  /// Get total savings
  double get totalSavings => data?.totalSavings ?? 0.0;
}

/// Cart status enum
enum CartStatus {
  /// Initial state, no data loaded yet
  initial,

  /// Loading cart data
  loading,

  /// Cart data loaded successfully
  loaded,

  /// Error loading cart data
  error,
}
