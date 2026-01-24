import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to store the selected category ID for navigation
/// Used when navigating from home page circular categories to category screen
class SelectedCategoryNotifier extends StateNotifier<int?> {
  SelectedCategoryNotifier() : super(null);

  void selectCategory(int categoryId) {
    state = categoryId;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedCategoryProvider =
    StateNotifierProvider<SelectedCategoryNotifier, int?>((ref) {
  return SelectedCategoryNotifier();
});
