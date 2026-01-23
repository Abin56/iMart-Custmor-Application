// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_detail_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductMetadataAdapter extends TypeAdapter<ProductMetadata> {
  @override
  final typeId = 10;

  @override
  ProductMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductMetadata(
      variantId: (fields[0] as num).toInt(),
      cachedAt: fields[3] as DateTime,
      etag: fields[1] as String?,
      lastModified: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductMetadata obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.variantId)
      ..writeByte(1)
      ..write(obj.etag)
      ..writeByte(2)
      ..write(obj.lastModified)
      ..writeByte(3)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productDetailCacheHash() =>
    r'535477b07c099888eccb53dbcddfdd5c3ce26d50';

/// See also [productDetailCache].
@ProviderFor(productDetailCache)
final productDetailCacheProvider =
    AutoDisposeProvider<ProductDetailCache>.internal(
      productDetailCache,
      name: r'productDetailCacheProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productDetailCacheHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductDetailCacheRef = AutoDisposeProviderRef<ProductDetailCache>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
