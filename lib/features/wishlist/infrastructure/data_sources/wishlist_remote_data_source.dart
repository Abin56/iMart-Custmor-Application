import 'package:dio/dio.dart';

import '../../../../app/core/network/api_client.dart';
import '../../domain/entities/wishlist_item.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItem>> getWishlist();
  Future<WishlistItem> addToWishlist(String productId);
  Future<void> removeFromWishlist(String wishlistItemId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  WishlistRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<WishlistItem>> getWishlist() async {
    try {
      final response = await _apiClient.get('/api/order/v1/wishlist/');

      List<dynamic> itemsList;

      // Handle both response formats (list vs paginated)
      if (response.data is List) {
        itemsList = response.data as List;
      } else if (response.data is Map && response.data['results'] != null) {
        itemsList = response.data['results'] as List;
      } else {
        return [];
      }

      // For each wishlist item, fetch complete product details
      final wishlistItems = <WishlistItem>[];

      for (final itemData in itemsList) {
        try {
          final wishlistId = itemData['id'] as int;
          final productVariantId = itemData['product_variant_id'].toString();

          // Get image from wishlist response if available
          final wishlistImageUrl = itemData['image']?.toString() ?? '';

          // Fetch product details
          final productResponse = await _apiClient.get(
            '/api/products/v1/variants/$productVariantId/',
          );

          final wishlistItem = _createWishlistItemFromProductResponse(
            wishlistId: wishlistId,
            productVariantId: productVariantId,
            productData: productResponse.data,
            fallbackImageUrl: wishlistImageUrl,
          );

          wishlistItems.add(wishlistItem);
        } catch (e) {
          // Fallback: Create item from basic data
          final basicItem = _createWishlistItemFromBasicData(itemData);

          wishlistItems.add(basicItem);
        }
      }

      return wishlistItems;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WishlistItem> addToWishlist(String productId) async {
    try {
      final requestData = {
        'product_variant_id': int.tryParse(productId) ?? productId,
      };

      final response = await _apiClient.post(
        '/api/order/v1/wishlist/',
        data: requestData,
      );

      if (response.statusCode == 201 && response.data != null) {
        // Fetch complete product details
        final productResponse = await _apiClient.get(
          '/api/products/v1/variants/$productId/',
        );

        return _createWishlistItemFromProductResponse(
          wishlistId: response.data['id'] as int,
          productVariantId: productId,
          productData: productResponse.data,
        );
      }

      throw Exception('Failed to add to wishlist');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        var errorMessage = 'Bad request';

        if (errorData is Map) {
          // Check for various field error keys
          if (errorData.containsKey('product_variant_id')) {
            final fieldError = errorData['product_variant_id'];
            errorMessage = fieldError is List
                ? fieldError.first
                : fieldError.toString();
          } else if (errorData.containsKey('product_variant')) {
            final fieldError = errorData['product_variant'];
            errorMessage = fieldError is List
                ? fieldError.first
                : fieldError.toString();
          } else if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'].toString();
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          }
        }

        throw Exception('API Error: $errorMessage');
      }

      throw Exception('Error adding to wishlist: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFromWishlist(String wishlistItemId) async {
    try {
      final response = await _apiClient.delete(
        '/api/order/v1/wishlist/$wishlistItemId/',
      );

      // Accept both 204 and 200 as success
      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      }

      throw Exception('Failed to remove from wishlist');
    } catch (e) {
      rethrow;
    }
  }

  /// Create WishlistItem from complete product API response
  WishlistItem _createWishlistItemFromProductResponse({
    required int wishlistId,
    required String productVariantId,
    required Map<String, dynamic> productData,
    String? fallbackImageUrl,
  }) {
    // Use the productVariantId from the wishlist response (guaranteed to exist)
    // rather than trying to extract it from productData
    final productId = productVariantId;
    final name = productData['name']?.toString() ?? 'Product';

    final priceStr = productData['price']?.toString() ?? '0';
    final discountedPriceStr = productData['discounted_price']?.toString();

    final mrp = double.tryParse(priceStr) ?? 0.0;
    final discountedPrice = discountedPriceStr != null
        ? double.tryParse(discountedPriceStr)
        : null;

    final displayPrice = discountedPrice ?? mrp;

    final discountPct = mrp > 0 && displayPrice < mrp
        ? ((1 - displayPrice / mrp) * 100).round()
        : 0;

    // Extract image from multiple sources
    var imageUrl = '';

    // Try primary_image first
    if (productData['primary_image'] != null &&
        productData['primary_image'].toString().isNotEmpty &&
        productData['primary_image'].toString() != 'null') {
      imageUrl = productData['primary_image'].toString();
    }

    // Fallback to media array
    if (imageUrl.isEmpty &&
        productData['media'] != null &&
        productData['media'] is List) {
      final mediaList = productData['media'] as List;

      if (mediaList.isNotEmpty) {
        final firstMedia = mediaList.first;
        if (firstMedia is Map && firstMedia['image'] != null) {
          imageUrl = firstMedia['image'].toString();
        }
      }
    }

    // Last resort: use image from wishlist response
    if (imageUrl.isEmpty &&
        fallbackImageUrl != null &&
        fallbackImageUrl.isNotEmpty &&
        fallbackImageUrl != 'null') {
      imageUrl = fallbackImageUrl;
    }

    // Process URL (add https:// if needed)
    final rawImageUrl = imageUrl;
    imageUrl = _processImageUrl(imageUrl);
    if (rawImageUrl.isNotEmpty) {}

    final unitLabel = productData['stock_unit']?.toString() ?? '';

    return WishlistItem(
      id: wishlistId,
      productId: productId,
      name: name,
      price: displayPrice,
      mrp: mrp,
      imageUrl: imageUrl,
      unitLabel: unitLabel,
      discountPct: discountPct,
      addedAt: DateTime.now(),
    );
  }

  /// Create WishlistItem from basic data (fallback)
  WishlistItem _createWishlistItemFromBasicData(Map<String, dynamic> json) {
    final productVariantId = json['product_variant_id']?.toString() ?? '';
    final imageUrl = json['image']?.toString() ?? '';
    final priceStr = json['price']?.toString() ?? '0';
    final mrpStr = json['mrp']?.toString() ?? priceStr;

    final price = double.tryParse(priceStr) ?? 0.0;
    final mrp = double.tryParse(mrpStr) ?? price;

    // Calculate discount percentage
    final discountPct = mrp > 0 && price < mrp
        ? ((1 - price / mrp) * 100).round()
        : 0;

    return WishlistItem(
      id: json['id'] as int,
      productId: productVariantId,
      name: json['name']?.toString() ?? 'Product',
      price: price,
      mrp: mrp,
      imageUrl: _processImageUrl(imageUrl),
      unitLabel: json['unit_label']?.toString() ?? '',
      discountPct: discountPct,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : null,
    );
  }

  /// Process image URL
  String _processImageUrl(String url) {
    if (url.isEmpty || url == 'string' || url == 'null') {
      return '';
    }

    // If already has protocol, return as-is (or upgrade http to https)
    if (url.startsWith('https://')) {
      return url;
    }

    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }

    // If it's a CDN URL without protocol (e.g., "grocery-application.b-cdn.net/...")
    if (url.contains('b-cdn.net') || url.contains('grocery-application')) {
      return 'https://$url';
    }

    // If relative path starting with /, add base URL
    if (url.startsWith('/')) {
      return 'https://grocery-application.b-cdn.net$url';
    }

    // Default: assume it's a CDN URL without protocol
    return 'https://$url';
  }
}
