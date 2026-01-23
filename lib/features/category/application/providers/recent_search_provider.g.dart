// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentSearchServiceHash() =>
    r'ce2c8503a49298521df255739ee52e1322510bd2';

/// Provider for recent search service
///
/// Copied from [recentSearchService].
@ProviderFor(recentSearchService)
final recentSearchServiceProvider =
    AutoDisposeProvider<RecentSearchService>.internal(
      recentSearchService,
      name: r'recentSearchServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentSearchServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentSearchServiceRef = AutoDisposeProviderRef<RecentSearchService>;
String _$recentSearchesHash() => r'02d3b357950e67e193b512f04c4182b975e625fc';

/// Provider for recent searches list
///
/// Copied from [RecentSearches].
@ProviderFor(RecentSearches)
final recentSearchesProvider =
    AutoDisposeNotifierProvider<RecentSearches, List<String>>.internal(
      RecentSearches.new,
      name: r'recentSearchesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentSearchesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RecentSearches = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
