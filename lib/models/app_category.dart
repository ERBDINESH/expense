import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoryType { defaultType, custom }

class AppCategory {
  final String id;
  final String name;
  final CategoryType type;

  AppCategory({
    required this.id,
    required this.name,
    required this.type,
  });

  factory AppCategory.fromFirestore(DocumentSnapshot doc, CategoryType type) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppCategory(
      id: data['categoryId'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      type: type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type == CategoryType.defaultType ? 'default' : 'custom',
    };
  }
}
