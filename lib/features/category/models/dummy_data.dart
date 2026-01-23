// ignore_for_file: avoid_redundant_argument_values

import 'category_item.dart';
import 'category_product.dart';

/// Static dummy data for the newcart feature
class DummyData {
  const DummyData._();

  /// Dummy categories
  static const List<CategoryItem> categories = [
    CategoryItem(
      id: '1',
      title: 'Fruits & Vegetables',
      assetPath: 'assets/images/no-image.png',
    ),
    CategoryItem(
      id: '2',
      title: 'Dairy & Eggs',
      assetPath: 'assets/images/dairy.png',
    ),
    CategoryItem(
      id: '3',
      title: 'Snacks & Beverages',
      assetPath: 'assets/images/snacks.png',
    ),
    CategoryItem(
      id: '4',
      title: 'Cleaning & Household',
      assetPath: 'assets/images/cleaning.png',
    ),
    CategoryItem(
      id: '5',
      title: 'Personal Care',
      assetPath: 'assets/images/personal_care.png',
    ),
    CategoryItem(
      id: '6',
      title: 'Bakery & Bread',
      assetPath: 'assets/images/bakery.png',
    ),
    CategoryItem(
      id: '7',
      title: 'Meat & Seafood',
      assetPath: 'assets/images/meat.png',
    ),
    CategoryItem(
      id: '8',
      title: 'Frozen Foods',
      assetPath: 'assets/images/frozen.png',
    ),
  ];

  /// Dummy products per category
  static const Map<String, List<CategoryProduct>> productsByCategory = {
    '1': [
      CategoryProduct(
        variantId: '101',
        variantName: 'Fresh Apples',
        name: 'Apples',
        price: '149',
        originalPrice: '180',
        weight: '1 kg',
        inStock: true,
        currentQuantity: 50,
      ),
      CategoryProduct(
        variantId: '102',
        variantName: 'Organic Bananas',
        name: 'Bananas',
        price: '49',
        weight: '6 pcs',
        inStock: true,
        currentQuantity: 100,
      ),
      CategoryProduct(
        variantId: '103',
        variantName: 'Fresh Tomatoes',
        name: 'Tomatoes',
        price: '12999',
        originalPrice: '15999',
        weight: '500 g',
        inStock: true,
        currentQuantity: 75,
      ),
      CategoryProduct(
        variantId: '104',
        variantName: 'Green Capsicum',
        name: 'Capsicum',
        price: '60',
        weight: '250 g',
        inStock: false,
        currentQuantity: 0,
      ),
      CategoryProduct(
        variantId: '105',
        variantName: 'Organic Spinach',
        name: 'Spinach',
        price: '25',
        weight: '250 g',
        inStock: true,
        currentQuantity: 30,
      ),
      CategoryProduct(
        variantId: '106',
        variantName: 'Fresh Carrots',
        name: 'Carrots',
        price: '40',
        weight: '500 g',
        inStock: true,
        currentQuantity: 60,
      ),
    ],
    '2': [
      CategoryProduct(
        variantId: '201',
        variantName: 'Farm Fresh Milk',
        name: 'Milk',
        price: '68',
        weight: '1 L',
        inStock: true,
        currentQuantity: 200,
      ),
      CategoryProduct(
        variantId: '202',
        variantName: 'White Eggs',
        name: 'Eggs',
        price: '89',
        weight: '12 pcs',
        inStock: true,
        currentQuantity: 80,
      ),
      CategoryProduct(
        variantId: '203',
        variantName: 'Fresh Paneer',
        name: 'Paneer',
        price: '120',
        weight: '200 g',
        inStock: true,
        currentQuantity: 40,
      ),
      CategoryProduct(
        variantId: '204',
        variantName: 'Greek Yogurt',
        name: 'Yogurt',
        price: '55',
        weight: '400 g',
        inStock: true,
        currentQuantity: 35,
      ),
    ],
    '3': [
      CategoryProduct(
        variantId: '301',
        variantName: 'Potato Chips',
        name: 'Chips',
        price: '30',
        weight: '100 g',
        inStock: true,
        currentQuantity: 150,
      ),
      CategoryProduct(
        variantId: '302',
        variantName: 'Orange Juice',
        name: 'Juice',
        price: '99',
        weight: '1 L',
        inStock: true,
        currentQuantity: 60,
      ),
      CategoryProduct(
        variantId: '303',
        variantName: 'Mixed Nuts',
        name: 'Nuts',
        price: '199',
        originalPrice: '249',
        weight: '200 g',
        inStock: true,
        currentQuantity: 25,
      ),
      CategoryProduct(
        variantId: '304',
        variantName: 'Cola Drink',
        name: 'Soft Drink',
        price: '40',
        weight: '500 ml',
        inStock: false,
        currentQuantity: 0,
      ),
    ],
    '4': [
      CategoryProduct(
        variantId: '401',
        variantName: 'Floor Cleaner',
        name: 'Floor Cleaner',
        price: '149',
        weight: '1 L',
        inStock: true,
        currentQuantity: 45,
      ),
      CategoryProduct(
        variantId: '402',
        variantName: 'Dish Wash Liquid',
        name: 'Dish Wash',
        price: '99',
        weight: '500 ml',
        inStock: true,
        currentQuantity: 70,
      ),
      CategoryProduct(
        variantId: '403',
        variantName: 'Toilet Cleaner',
        name: 'Toilet Cleaner',
        price: '79',
        weight: '500 ml',
        inStock: true,
        currentQuantity: 55,
      ),
    ],
    '5': [
      CategoryProduct(
        variantId: '501',
        variantName: 'Herbal Shampoo',
        name: 'Shampoo',
        price: '199',
        weight: '200 ml',
        inStock: true,
        currentQuantity: 40,
      ),
      CategoryProduct(
        variantId: '502',
        variantName: 'Body Lotion',
        name: 'Lotion',
        price: '249',
        originalPrice: '299',
        weight: '200 ml',
        inStock: true,
        currentQuantity: 30,
      ),
      CategoryProduct(
        variantId: '503',
        variantName: 'Face Wash',
        name: 'Face Wash',
        price: '149',
        weight: '100 ml',
        inStock: true,
        currentQuantity: 50,
      ),
    ],
    '6': [
      CategoryProduct(
        variantId: '601',
        variantName: 'White Bread',
        name: 'Bread',
        price: '45',
        weight: '400 g',
        inStock: true,
        currentQuantity: 100,
      ),
      CategoryProduct(
        variantId: '602',
        variantName: 'Chocolate Muffin',
        name: 'Muffin',
        price: '35',
        weight: '1 pc',
        inStock: true,
        currentQuantity: 25,
      ),
    ],
    '7': [
      CategoryProduct(
        variantId: '701',
        variantName: 'Chicken Breast',
        name: 'Chicken',
        price: '299',
        weight: '500 g',
        inStock: true,
        currentQuantity: 20,
      ),
      CategoryProduct(
        variantId: '702',
        variantName: 'Fresh Fish',
        name: 'Fish',
        price: '350',
        weight: '500 g',
        inStock: false,
        currentQuantity: 0,
      ),
    ],
    '8': [
      CategoryProduct(
        variantId: '801',
        variantName: 'Frozen Peas',
        name: 'Peas',
        price: '85',
        weight: '500 g',
        inStock: true,
        currentQuantity: 60,
      ),
      CategoryProduct(
        variantId: '802',
        variantName: 'Ice Cream',
        name: 'Ice Cream',
        price: '199',
        weight: '500 ml',
        inStock: true,
        currentQuantity: 35,
      ),
    ],
  };

  /// Get products for a category
  static List<CategoryProduct> getProductsForCategory(String? categoryId) {
    if (categoryId == null) return [];
    return productsByCategory[categoryId] ?? [];
  }
}
