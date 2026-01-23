/// Category data model with title, id, and optional images (local or network)
class CategoryItem {
  const CategoryItem({
    required this.title,
    this.id,
    this.assetPath,
    this.imageUrl,
  });

  final String title;
  final String? id;
  final String? assetPath;
  final String? imageUrl;
}
