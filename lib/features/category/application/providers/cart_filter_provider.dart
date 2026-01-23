import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_filter_provider.g.dart';

/// Filter state for category products
class CartFilterState extends Equatable {
  const CartFilterState({
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
    this.isDiscounted,
    this.ordering,
  });

  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;
  final bool? isDiscounted;
  final String? ordering;

  @override
  List<Object?> get props => [
    searchQuery,
    minPrice,
    maxPrice,
    isDiscounted,
    ordering,
  ];

  CartFilterState copyWith({
    String? Function()? searchQuery,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    bool? Function()? isDiscounted,
    String? Function()? ordering,
  }) {
    return CartFilterState(
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      minPrice: minPrice != null ? minPrice() : this.minPrice,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      isDiscounted: isDiscounted != null ? isDiscounted() : this.isDiscounted,
      ordering: ordering != null ? ordering() : this.ordering,
    );
  }

  /// Check if any filter is active
  bool get hasActiveFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      isDiscounted != null ||
      (ordering != null && ordering!.isNotEmpty);

  /// Clear all filters
  CartFilterState clearAll() => const CartFilterState();
}

/// Notifier for managing filter state
@riverpod
class CartFilter extends _$CartFilter {
  @override
  CartFilterState build() {
    return const CartFilterState();
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: () => query);
  }

  void setPriceRange({double? min, double? max}) {
    state = state.copyWith(minPrice: () => min, maxPrice: () => max);
  }

  void setDiscountedFilter(bool? isDiscounted) {
    state = state.copyWith(isDiscounted: () => isDiscounted);
  }

  void setOrdering(String? ordering) {
    state = state.copyWith(ordering: () => ordering);
  }

  void setMultipleFilters({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    bool? isDiscounted,
    String? ordering,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery != null ? () => searchQuery : null,
      minPrice: minPrice != null ? () => minPrice : null,
      maxPrice: maxPrice != null ? () => maxPrice : null,
      isDiscounted: () => isDiscounted,
      ordering: ordering != null ? () => ordering : null,
    );
  }

  void clearFilters() {
    state = const CartFilterState();
  }
}

/// Ordering options for products
class OrderingOption {
  const OrderingOption({required this.label, required this.value});

  final String label;
  final String value;

  static const List<OrderingOption> options = [
    OrderingOption(label: 'Price: Low to High', value: 'min_price'),
    OrderingOption(label: 'Price: High to Low', value: '-min_price'),
    OrderingOption(label: 'Rating: High to Low', value: '-rating'),
    OrderingOption(label: 'Rating: Low to High', value: 'rating'),
    OrderingOption(label: 'Newest First', value: '-created_at'),
    OrderingOption(label: 'Oldest First', value: 'created_at'),
  ];
}
