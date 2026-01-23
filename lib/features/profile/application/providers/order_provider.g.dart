// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderHash() => r'41996a2a30ea1393b3fcb438bc9537ed10d3de3f';

/// Order Notifier for managing orders state
///
/// Copied from [Order].
@ProviderFor(Order)
final orderProvider = NotifierProvider<Order, OrderState>.internal(
  Order.new,
  name: r'orderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Order = Notifier<OrderState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
